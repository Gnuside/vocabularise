

require 'dm-core'

module VocabulariSe

	# a queue entry
	class CrawlerQueueEntry
		include DataMapper::Resource

		property :id, Serial
		property :cquery,   String, :unique => true
		property :handler, String, :unique => true
		property :priority, Integer, :default => 0
		property :created_at, Integer, :required => true                        
	end

	class CrawlerQueue
		#
		# FIXME: do something for priority

		def initialize
		end

		def include? handler, query
			req = {
				:handler => handler,
			   	:cquery => query
			}
			resp = CrawlerQueueEntry.first req
			return (not resp.nil?)
		end

=begin
		def []= key, resp
			CrawlerQueueEntry.transaction do
				now = Time.now

				resp = CrawlerQueueEntry.get key
				resp.destroy if resp

				req_create = { 
					:id => key,
					:data => Marshal.dump( data ),
					:created_at => now.to_i,
					:expires_at => now.to_i + @timeout,
				}
				resp = CrawlerQueueEntry.create req_create
				resp.save

				self.include? key
			end
		rescue DataMapper::SaveFailureError => e
			STDERR.puts e.message
			raise RuntimeError, "unable to set data"
		end

		def [] key
			now = Time.now
			req = { 
				:id => key,
				:expires_at.gt => now.to_i
			}
			resp = CrawlerQueueEntry.first req
			if resp then return Marshal.load( resp.data )
			else return nil
			end
		end
=end

		def push handler, query, priority
			CrawlerQueueEntry.transaction do
				now = Time.now
				req_find = {
					:handler => handler,
					:cquery => query
				}
				req_create = {
					:handler => handler,
					:cquery => query,
					:priority => priority,
					:created_at => now.to_i
				}
				resp = CrawlerQueueEntry.first_or_create req_find, req_create
				resp.save!
			end
		end

		def first
			req = { 
				:order => [:priority, :created_at]
			}
			resp = CrawlerQueueEntry.first req
			return resp
		end

		def shift
			req = { 
				:order => [:priority, :created_at]
			}
			resp = CrawlerQueueEntry.first req
			resp.destroy if resp
		end

		def each &blk
			now = Time.now
			resp = CrawlerQueueEntry.all
			resp.each do |x| 
				yield x 
			end
			raise RuntimeError
		end
	end
end

