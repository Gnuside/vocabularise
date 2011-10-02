

require 'dm-core'

module VocabulariSe

	# a queue entry
	class CrawlerQueueEntry
		include DataMapper::Resource

		property :id,   String, :key => true
		property :handler, String, :key => true
		property :data, String, :required => true 
		property :priority, Integer, :required => true                        

	end

	class CrawlerQueue
		#
		# FIXME: do something for priority

		def initialize
		end

		def include? key, handler
			now = Time.now
			req = { :id => key }
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

