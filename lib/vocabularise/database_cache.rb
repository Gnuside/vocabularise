
require 'dm-core'
require 'vocabularise/generic_cache'

require 'monitor'
require 'rdebug/base'

module VocabulariSe

	class DatabaseCacheEntry
		include DataMapper::Resource

		property :id,   String, :key => true
		property :data, String, :required => true 
		property :created_at, Integer, :required => true                        
		property :expires_at, Integer, :required => true                        
	end

	class DatabaseCache < GenericCache

		def initialize timeout
			@timeout = timeout
			@monitor = Monitor.new
			@debug = true
		end

		def include? key
			rdebug "key = %s" % key
			now = Time.now
			req = { 
				:id => key,
				:expires_at.gt => now.to_i
			}
			resp = DatabaseCacheEntry.first req
			rdebug "return : %s" % (not resp.nil?)
			return (not resp.nil?)
		end

		def []= key, data
			DatabaseCacheEntry.transaction do
				now = Time.now

				resp = DatabaseCacheEntry.get key
				resp.destroy if resp

				req_create = { 
					:id => key,
					:data => Marshal.dump( data ),
					:created_at => now.to_i,
					:expires_at => now.to_i + @timeout,
				}
				resp = DatabaseCacheEntry.create req_create
				unless resp.save then
					raise RuntimeError, "unable to save"
				end

				return self.include? key
			end
		#rescue DataMapper::SaveFailureError => e
		#	STDERR.puts e.message
		#	raise RuntimeError, "unable to set data"
		end

		def [] key
			now = Time.now
			req = { 
				:id => key,
				:expires_at.gt => now.to_i
			}
			resp = DatabaseCacheEntry.first req
			if resp then return Marshal.load( resp.data )
			else return nil
			end
		end

		def each &blk
			now = Time.now
			req = { 
				:expires_at.gt => now.to_i,
			}
			resp = DatabaseCacheEntry.all req
			resp.each do |x| yield x ; end
		end
	end
end
