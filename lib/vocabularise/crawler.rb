
require 'thread'
require 'monitor'

require 'vocabularise/queue'
require 'vocabularise/hit_counter'

require 'rdebug/base'

module VocabulariSe

	class Crawler

		class DeferredRequest < RuntimeError ; end

		MODE_INTERACTIVE = :interactive
		MODE_PASSIVE = :passive

		COUNTER_WIKIPEDIA_RATE = :wikipedia_rate
		COUNTER_WIKIPEDIA_CURRENT = :wikipedia_current

		COUNTER_MENDELEY_RATE = :mendeley_rate
		COUNTER_MENDELEY_CURRENT = :mendeley_current


		REQUEST_INTERNAL_RELATED = 'internal:related'
		REQUEST_INTERNAL_EXPECTED = 'internal:expected'
		REQUEST_INTERNAL_CONTROVERSIAL = 'internal:controversial'
		REQUEST_INTERNAL_AGGREGATING = 'internal:aggregating'

		def initialize config
			@config = config
			@queue = {}
			
			# prepare multiple queues for multiple threads,
			# to be more efficient & not being blocked by a given api
			[:wikipedia,:mendeley,:internal].each do |key|
				@queue[key] = Queue.new key
				@queue[key].empty!
			end

			@debug = true
			@monitor = Monitor.new
		end


		# request a request
		#
		# if request is in cache then send a result
		def request handler, query, mode=MODE_PASSIVE
			rdebug "handler = %s, query = %s, mode = %s" % [ handler, query.inspect, mode ]

			result = nil
			deferred = false

			@monitor.synchronize do 
				cache_key = _cache_key(handler, query)
				if @config.cache.include? cache_key then
					rdebug "request in cache (%s, %s)" % [handler, query.inspect]
					# send result from cache
					result = @config.cache[cache_key]
					break
				end
					
				found = false
				@queue.each do |key,queue|
					if queue.include? handler, query then
						rdebug "request in #{key} queue (%s, %s)" % [handler, query.inspect]

						# increase queue priority if passive mode
						queue.stress handler, query if mode == MODE_PASSIVE

						# you'll have to wait
						deferred = true
						found = true
						break
					end
				end
				break if found

				rdebug "request nowhere (%s, %s)" % [handler, query]
				# neither in cache nor in queue
				# we add request to the queue

				priority = priority_from_mode mode

				@queue.each do |key,queue|
					if handler =~ /^#{key}/ then
						queue.push handler, query, priority
					end
				end

				deferred = true
			end
			raise DeferredRequest if deferred
			return result
		end



		# no need to be synchronized
		def run
			Thread.abort_on_exception = true
			@queue.each do |key,queue|
				Thread.new( key, queue ) do |key, queue|
					rdebug "/#{key}/ crawler up and running!"
					loop do
						rdebug "/#{key}/ loop start"
						
						# get first in queue, by priority
						if queue.empty? then
							sleep 1
							next
						end

						e_handler, e_query, e_priority = queue.pop

						rdebug "/#{key}/ handling %s, %s, %s" % [ e_handler, e_query, e_priority ]
	
						begin
							# call proper handler for request
							process e_handler, e_query, e_priority
						rescue DeferredRequest
							# execution failed, try it again later
							rdebug "/#{key}/ pushing back in queue %s, %s, %s" % [ e_handler, e_query, e_priority ]
							queue.push e_handler, e_query, (e_priority - 1)
						end

					end
				end
			end
		end

		def find_handlers handle
			RequestHandler.subclasses.select do |rh|
				rh.handles? handle
			end
		end

		private

		# no need to be synchronized
		def _cache_key action, intag
			key = "%s:%s" % [action,intag]	
		end


		def process handle, query, mode
			rdebug "handle = %s, query = %s, mode = %s" % [ handle, query.inspect, mode ]
			sleep 10 #DEBUG FIXME
			found = false
			find_handlers( handle ).each do |handler_class|
				rdebug "handler found for #{handle} : #{handler_class}"
				found = true
				begin
					handler_instance = handler_class.new( @config, self )

					# may raise a DeferredRequest :-)
					result = handler_instance.process( handle, query, mode )

					# may not be executed (do not worry) ;-)
					cache_key = _cache_key(handle, query)
					@cache[cache_key] = result if handler_instance.cache_result?
				end
			end
			rdebug "no handler found for #{handle}!" unless found
		end
		
		def priority_from_mode mode
			priority = case mode 
					   when MODE_INTERACTIVE then Queue::PRIORITY_HIGH
					   when MODE_PASSIVE then Queue::PRIORITY_LOW
					   else Queue::PRIORITY_NORMAL
					   end
		end
	end

end

