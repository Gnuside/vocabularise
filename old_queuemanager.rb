
# no need to be synchronized
def run
	Thread.abort_on_exception = true
	@queue.each do |key,queue|
		Thread.new( key, queue ) do |key, queue|
			rdebug "/#{key}/ crawler up and running!"
			loop do
				# get first in queue, by priority
				queue_empty = false
				@monitor.synchronize do 
					queue_empty = queue.empty? 
				end

				if queue_empty then
					rdebug "/#{key}/ queue empty"
					queue.dump("x" + key.to_s)
					sleep SLEEP_TIME
					next
				end

				e_handler, e_query, e_priority = nil, nil, nil
				@monitor.synchronize do 
					e_handler, e_query, e_priority = queue.first
					queue.lock e_handler, e_query
				end

				rdebug "/#{key}/ handling %s, %s, %s" % [ e_handler, e_query.inspect, e_priority ]

				begin
					# call proper handler for request
					process e_handler, e_query, e_priority
					# success, we remove the request from the queue
					@monitor.synchronize do 
						queue.delete e_handler, e_query
					end

				rescue HttpError => e
					# Bad luck. Forget it dude :-)
					# Should not happen. Mendeley doc states that we only have to wait and retry later...
					rdebug "/#{key}/ failed for %s, %s, %s" % [ e_handler, e_query.inspect, (e_priority/2) ]
					rdebug "/#{key}/ remote API is broken at this time %s, %s, %s" % [ e_handler, e_query.inspect, (e_priority / 2) ]
					@monitor.synchronize do 
						queue.delete e_handler, e_query
					end

				rescue DeferredRequest
					# execution failed, try it again later
					rdebug "/#{key}/ failed for %s, %s, %s" % [ e_handler, e_query.inspect, (e_priority/2) ]
					rdebug "/#{key}/ pushing back in queue %s, %s, %s" % [ e_handler, e_query.inspect, (e_priority / 2) ]
					@monitor.synchronize do 
						queue.delete e_handler, e_query
						queue.push e_handler, e_query, ( 1 + (e_priority / 2) )
					end
				end

			end #loop

		end # thread
	end #queue.each
end
