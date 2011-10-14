
require 'monitor'
require 'base64'
require 'rdebug/base'

require 'vocabularise/model'

module VocabulariSe

	class Cache

		MAX_CHUNK_SIZE = 5000

		def initialize timeout
			@timeout = timeout
			@monitor = Monitor.new
			@debug = false
		end

		def include? key
			rdebug "key = %s" % key
			now = Time.now
			req = { 
				:id => key,
				:expires_at.gt => now.to_i

			}
			resp = CacheEntry.first req
			rdebug "return : %s" % (not resp.nil?)
			return (not resp.nil?)
		end

		def []= key, value
		#	CacheEntry.raise_on_save_failure = true 
			CacheEntry.transaction do
				now = Time.now

				#:data => data,
				#
				req_update = { 
					:id => key,
					:created_at => now.to_i,
					:expires_at => now.to_i + @timeout,
				}

				resp = CacheEntry.get key
				if resp then
					resp.cache_chunks.destroy
					resp.destroy
				end

				begin
					resp = CacheEntry.new req_update
				rescue DataMapper::SaveFailureError => e
					#STDERR.puts resp.errors
					STDERR.puts CacheEntry.errors
					STDERR.puts e.message
					raise e
				end


				value_marshal = ::Marshal.dump(value) if value
				value_64 = Base64.encode64(value_marshal)


				chunk_64 = []
				if value_64.size > MAX_CHUNK_SIZE then
					split_count = (value_64.size / MAX_CHUNK_SIZE)+ (value_64.size % MAX_CHUNK_SIZE ? 1 : 0)
					chunk_64 = value_64.unpack("a#{MAX_CHUNK_SIZE}" * split_count)
				else
					chunk_64 = [ value_64 ]
				end

				part = 0
				chunk_64.each do |chunk|
					resp.cache_chunks.new :data => chunk, :part => part
					part += 1
				end

				begin
					resp.save
				rescue DataMapper::SaveFailureError => e
					pp resp.errors
					#STDERR.puts CacheEntry.errors
					STDERR.puts e.message
					raise e
				end


				return self.include? key
			end
		end

		def [] key
			now = Time.now
			req = { 
				:id => key,
				:expires_at.gt => now.to_i
			}
			result = nil
			CacheEntry.transaction do
				resp = CacheEntry.first req
				if resp 
					value_64_array = resp.cache_chunks(:order => [:part.asc]).map{ |chunk| chunk.data }
					value_64 = value_64_array.pack("a#{MAX_CHUNK_SIZE}"*value_64_array.size)
					rdebug "value_64 = %s" % value_64
					value_marshal = Base64.decode64(value_64)
					rdebug "value_marshal = %s" % value_marshal
					value = ::Marshal.load(value_marshal)
					rdebug "value = %s" % value
					result = value
				end
			end
			return result
		end


		def expunge!
			now = Time.now
			req = { 
				:expires_at.lt => now.to_i,
			}
			CacheEntry.transaction do
				resp = CacheEntry.all req
				resp.cache_chunks.all.destroy
				resp.destroy
			end
		end

		def empty!
			CacheEntry.transaction do
				CacheEntry.all.destroy
			end
		end

		def each &blk
			now = Time.now
			req = { 
				:expires_at.gt => now.to_i,
			}
			resp = CacheEntry.all req
			resp.each do |x| yield x ; end
		end
	end
end
