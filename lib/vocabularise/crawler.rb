
require 'thread'
require 'monitor'

require 'vocabularise/crawler_queue'
require 'vocabularise/hit_counter'

require 'rdebug/base'

module VocabulariSe

	class Crawler

		MODE_INTERACTIVE = :interactive
		MODE_PASSIVE = :passive

		COUNTER_WIKIPEDIA_RATE = :wikipedia_rate
		COUNTER_WIKIPEDIA_CURRENT = :wikipedia_current

		COUNTER_MENDELEY_RATE = :mendeley_rate
		COUNTER_MENDELEY_CURRENT = :mendeley_current


		REQUEST_RELATED = 'related'
		REQUEST_EXPECTED = 'expected'
		REQUEST_CONTROVERSIAL = 'controversial'
		REQUEST_AGGREGATING = 'aggregating'

		def initialize config
			@config = config
			@queue = CrawlerQueue.new
			@queue.empty!

			@debug = true
			@monitor = Monitor.new

			# FIXME: add multiple crawling threads for more efficiency
			# or to prevent blocked requests
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

				elsif @queue.include? handler, query then
					rdebug "request in queue (%s, %s)" % [handler, query]

					# FIXME: increase queue priority
					# you'll have to wait
					
					deferred = true
				else
					rdebug "request nowhere (%s, %s)" % [handler, query]
					# neither in cache nor in queue
					# we add request to the queue
					priority = case mode 
							   when MODE_INTERACTIVE then 5
							   when MODE_PASSIVE then 1
							   else 1
							   end
					@queue.push handler, query, priority
					deferred = true
				end
			end
			raise DeferredError if deferred
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
			Thread.new do
				rdebug 'crawler up and running!'
				while true
					rdebug 'loop start (sleep)'
					sleep 1
					# get first in queue, by priority
					next if @queue.empty?
					rdebug 'queue first'

					e_handler, e_query, e_priority = @queue.first

					rdebug 'handling %s, %s, %s' % [ e_handler, e_query, e_priority ]
					# call proper handler for request
					process e_handler, e_query, e_priority

					rdebug 'shifting queue'
					@queue.shift
				end
			end
		end

		private

		# no need to be synchronized
		def _cache_key action, intag
			key = "%s:%s" % [action,intag]	
		end

		def find_handlers handle
			CrawlerHandler::Base.subclasses.find_all do |handler|
				handler.handles? handle
			end
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
	end

end

