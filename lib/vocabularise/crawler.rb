
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


		SLEEP_TIME = 5
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
		end #initialize


		# request a request
		#
		# if request is in cache then send a result
		def request handler, query, mode=MODE_PASSIVE
			rdebug "handler = %s, query = %s, mode = %s" % [ handler, query.inspect, mode ]

			result = nil
			deferred = false
			found = false

			@monitor.synchronize do 
				cache_key = _cache_key(handler, query)
				if @config.cache.include? cache_key then
					rdebug "request in cache (%s, %s)" % [handler, query.inspect]
					# send result from cache
					result = @config.cache[cache_key]
					found = true
					break
				elsif result.nil? then
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

					unless found then
						rdebug "request nowhere (%s, %s)" % [handler, query]
						# neither in cache nor in queue
						# we add request to the queue

						priority = priority_from_mode mode

						@queue.each do |key,queue|
							if handler =~ /^#{key}/ then
								queue.push handler, query, priority
								deferred = true
								break
							end
						end
					end
				end
			end
			raise DeferredRequest if deferred
			return result
		end # request



		# no need to be synchronized
		def run
			Thread.abort_on_exception = true
			@queue.each do |key,queue|
				Thread.new( key, queue ) do |key, queue|
					rdebug "/#{key}/ crawler up and running!"
					loop do

						# get first in queue, by priority
						if queue.empty? then
							rdebug "/#{key}/ queue empty"
							sleep SLEEP_TIME
							next
						end

						e_handler, e_query, e_priority = nil, nil, nil
						@monitor.synchronize do 
							e_handler, e_query, e_priority = queue.pop
						end

						rdebug "/#{key}/ handling %s, %s, %s" % [ e_handler, e_query, e_priority ]

						begin
							# call proper handler for request
							process e_handler, e_query, e_priority
						rescue DeferredRequest
							# execution failed, try it again later
							rdebug "/#{key}/ failed for %s, %s, %s" % [ e_handler, e_query, (e_priority/2) ]
							rdebug "/#{key}/ pushing back in queue %s, %s, %s" % [ e_handler, e_query, (e_priority / 2) ]
							@monitor.synchronize do 
								queue.push e_handler, e_query, (e_priority / 2)
							end
						end

					end #loop

				end # thread
			end #queue.each
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


		def process handle, query, priority
			handle_str = "handle = %s, query = %s, priority = %s" % [ handle, query.inspect, priority ]
			rdebug handle_str
			sleep SLEEP_TIME #DEBUG FIXME
			found = false
			find_handlers( handle ).each do |handler_class|
				rdebug "handler found for #{handle} : #{handler_class}"
				found = true
				begin
					handler_instance = handler_class.new( @config, self )

					# may raise a DeferredRequest :-)
					result = handler_instance.process( handle, query, priority )

					# may not be executed (do not worry) ;-)
					if handler_instance.cache_result? then
						rdebug "success && caching %s" % handle_str

						cache_key = _cache_key(handle, query)
						@config.cache[cache_key] = result 
					else
						rdebug "success && thrashing %s" % handle_str
					end
				end
			end
			rdebug "no handler found for #{handle}!" unless found
			raise RuntimeError, "no handler found for #{handle}!" unless found
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

