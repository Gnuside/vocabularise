
require 'dm-core'
#require 'dm-types/support/dirty_minder'

require 'monitor'
require 'base64'
require 'rdebug/base'

=begin
module DataMapper
	class Property
		class Marshal < Text
			class BigdataError < RuntimeError ; end

			primitive ::Object
			#load_as ::Object

			def load(value64)
				#@debug = true
				#rdebug "loading value = %s" % value64.inspect
				value = Base64.decode64(value64) if value64
				::Marshal.load(value) if value
			end

			def dump(value)
				#@debug = true
				#rdebug "dumping value = %s" % value.inspect
				value64 = ::Marshal.dump(value) if value
				res = Base64.encode64(value64) if value64
				if res.size > 125000 then
					raise BigdataError, res.size.to_s
				end
				res
			end

			def typecast(value)
				value
			end

		#	include ::DataMapper::Property::DirtyMinder
		end
	end
end
=end

module VocabulariSe

	class CacheEntry
		include DataMapper::Resource

		property :id,   String, :key => true
		property :created_at, Integer, :required => true                        
		property :expires_at, Integer, :required => true                        

		has n, :cache_chunks
	end

	class CacheChunk
		include DataMapper::Resource

		property :id, Serial
		property :part, Integer, :required => true 
		property :data, Text, :required => true 

		belongs_to :cache_entry
	end

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

				resp = CacheEntry.create req_update

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

				raise RuntimeError unless resp.save 

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
			CacheEntry.all.destroy
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
