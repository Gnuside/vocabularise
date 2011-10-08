
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
			@queue[:wikipedia] = Queue.new
			@queue[:mendeley] = Queue.new
			@queue[:internal] = Queue.new

			@queue.each { |k,queue| queue.empty! }

			@debug = true
			@monitor = Monitor.new
		end


		# request a request
		#
		# if request is in cache then send a result
		def request handler, query, mode=MODE_PASSIVE
			rdebug "handler = %s, query = %s, mode = %s" % [ handler, query, mode ]

			result = nil
			deferred = false

			@monitor.synchronize do 
				cache_key = _cache_key(handler, query)
				if @config.cache.include? cache_key then
					rdebug "request in cache (%s, %s)" % [handler, query]
					# send result from cache
					result = @config.cache[cache_key]
					break
				end
					
				found = false
				@queue.each do |key,queue|
					if queue.include? handler, query then
						rdebug "request in #{key} queue (%s, %s)" % [handler, query]

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



=begin
		# no need to be synchronized
		def handle req
			rdebug "begin-run %s, %s" % [req.handler, req.cquery]

			result = nil
			cache_key = _cache_key(req.handler, req.cquery)

			find_handlers( req.handler ) do |handler|
				handler.process req
			end

			case req.handler
			when REQUEST_RELATED then
				result = VocabulariSe::Utils.related_tags @config, req.cquery
				rdebug "related tags = %s" % result.inspect

			when REQUEST_EXPECTED then 
				# do something
			else
				rdebug "unknown handler for %s" % req.inspect
			end

			@config.cache[cache_key] = result if result
			STDERR.puts "request end-run %s, %s" % [req.handler, req.cquery]
		end
=end


		# no need to be synchronized
		def run
			Thread.abort_on_exception = true
			@queue.each do |key,queue|
				Thread.new do
					rdebug 'crawler up and running!'
					while true
						rdebug 'loop start (sleep)'
						sleep 5
						# get first in queue, by priority
						next if queue.empty?
						rdebug 'queue first'

						e_handler, e_query, e_priority = queue.pop

						rdebug 'handling %s, %s, %s' % [ e_handler, e_query, e_priority ]
	
						begin
							# call proper handler for request
							process e_handler, e_query, e_priority
						rescue DeferredRequest
							# execution failed, try it again later
							queue.push e_handler, e_query, (e_priority - 1)
						end

						rdebug 'shifting queue'
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


		def process handler, query, mode
			rdebug "handler = %s, query = %s, mode = %s" % [ handler, query, mode ]
			sleep 20
			find_handlers( handler ).each do |handler|
				begin
					handler.new( self, handler, query, mode ).process
				end
			end
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

