

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

		# increase priority of given handler/query
		def stress handler, query
			QueueEntry.transaction do
				req = {
					:queue => @name,
					:handler => handler,
					:cquery => JSON.generate([query])
				}
				resp = QueueEntry.first req
				if resp then
					resp.priority = resp.priority + PRIORITY_NORMAL
					resp.save
				end
				self
			end
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
			QueueEntry.transaction do
				resp = QueueEntry.all( :queue => @name )
				resp.each do |entry|
					yield entry.handler, entry.cquery, entry.priority
				end
			end
		end

		def empty!
			QueueEntry.transaction do
				resp = QueueEntry.all( :queue => @name ).destroy
			end
			self
		end

		def empty?
			return (size == 0)
		end

		def size
			count = 0
			QueueEntry.transaction do
				count = QueueEntry.all( :queue => @name ).count
			end
			return count
		end

		#
		# Display queue content
		#
		def dump prefix
			each do |h,q,p|
				puts ""
				puts "queue /%s/ => %s, %s, %s" % [prefix, h, q, p]
				puts ""
			end
		end
	end
end

