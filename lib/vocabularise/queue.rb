

require 'json'
require 'vocabularise/model'

module VocabulariSe


	class Queue
		#
		# FIXME: do something for priority

		class EmptyQueueError < RuntimeError ; end

		PRIORITY_HIGH = 100
		PRIORITY_NORMAL = 50
		PRIORITY_LOW = 25


		def initialize name
			@name = name.to_s
		end

		def include? handler, query
			req = {
				:queue => @name,
				:handler => handler,
				:cquery => JSON.generate([query])
			}
			resp = QueueEntry.first req
			return (not resp.nil?)
		end


		def push handler, query, priority=nil
			QueueEntry.transaction do
				now = Time.now
				req_find = {
					:queue => @name,
					:handler => handler,
					:cquery => JSON.generate([query])
				}
				req_create = {
					:queue => @name,
					:handler => handler,
					:cquery => JSON.generate([query]),
					:created_at => now.to_i
				}
				req_create[:priority] = priority.to_i unless priority.nil?

				resp = QueueEntry.first req_find
				if resp.nil? then
					resp = QueueEntry.new req_create
				end

				begin
					resp.save
				rescue DataMapper::SaveFailureError => e
					pp resp.errors
					raise e
				end
			end
			return self
		end


		def first
			req = {
				:queue => @name,
				:order => [:priority.desc, :created_at.asc, :id.asc]
			}
			resp = QueueEntry.first req
			if resp
				then return resp.handler, JSON.parse(resp.cquery).first, resp.priority
			else
				raise EmptyQueueError
			end
		end


		def shift
			req = {
				:queue => @name,
				:order => [:priority.desc, :created_at.asc, :id.asc]
			}
			resp = QueueEntry.first req
			if resp then resp.destroy
			else raise EmptyQueueError
			end
			return self
		end


		def pop
			handler, query, priority = nil, nil, nil
			QueueEntry.transaction do
				handler, query, priority = self.first
				shift
			end
			return handler, query, priority
		end

		def each &blk
			now = Time.now
			resp = QueueEntry.all :queue => @name
			resp.each do |x|
				yield x
			end
			raise RuntimeError
		end

		def empty!
			QueueEntry.transaction do
				resp = QueueEntry.all :queue => @name
				resp.each { |x| x.destroy }
			end
			self
		end

		def empty?
			return (size == 0)
		end

		def size
			return QueueEntry.count( :queue => @name )
		end
	end
end

