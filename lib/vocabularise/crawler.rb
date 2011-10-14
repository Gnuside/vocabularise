
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


		SLEEP_TIME = 10
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
			handle_str = "handler = %s, query = %s, mode = %s" % [ handler, query.inspect, mode ]
			rdebug handle_str

			result = nil
			deferred = false
			found = false
			in_cache = false
			in_queue = {}
			some_queue = nil
			cache_key = _cache_key(handler, query)

			@monitor.synchronize do 
				in_cache = @config.cache.include? cache_key
				@queue.each do |key,queue|
					in_queue[key] = @queue[key].include? handler, query
					#DEBUG
					@queue[key].dump key
					if in_queue[key] then
						some_queue = key
						break
					end
				end
			end

			if in_cache then
				rdebug "request in cache (%s, %s)" % [handler, query.inspect]
				# send result from cache
				@monitor.synchronize do 
					result = @config.cache[cache_key]
				end
			elsif not some_queue.nil? then
				rdebug "request in #{some_queue} queue (%s)" % handle_str

				# increase queue priority if passive mode
				@monitor.synchronize do	
					#DEBUG
					@queue[some_queue].dump some_queue
					@queue[some_queue].stress handler, query if mode == MODE_PASSIVE
				end

				# you'll have to wait
				deferred = true
			else
				rdebug "request nowhere (%s, %s)" % [handler, query.inspect]
				# neither in cache nor in queue
				# we add request to the queue

				priority = priority_from_mode mode

				@queue.each do |key,queue|
					if handler =~ /^#{key}/ then
						@monitor.synchronize do
							queue.push handler, query, priority
						end
						deferred = true
						break
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
						end

						rdebug "/#{key}/ handling %s, %s, %s" % [ e_handler, e_query.inspect, e_priority ]

						begin
							# call proper handler for request
							process e_handler, e_query, e_priority
							# success, we remove the request from the queue
							@monitor.synchronize do 
								queue.shift
							end
						rescue DeferredRequest
							# execution failed, try it again later
							rdebug "/#{key}/ failed for %s, %s, %s" % [ e_handler, e_query.inspect, (e_priority/2) ]
							rdebug "/#{key}/ pushing back in queue %s, %s, %s" % [ e_handler, e_query.inspect, (e_priority / 2) ]
							@monitor.synchronize do 
								queue.shift
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
			handlers = find_handlers( handle )
			rdebug "handlers => %s" % handlers.inspect
			handlers.each do |handler_class|
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
						@monitor.synchronize do 
							@config.cache[cache_key] = result 
						end
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

