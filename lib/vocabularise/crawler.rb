
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
			@debug = true
			@monitor = Monitor.new

			# FIXME: add multiple crawling threads for more efficiency
			# or to prevent blocked requests
		end


		# request a request
		#
		# if request is in cache then send a result
		def request handler, query, mode

			result = nil
			@monitor.synchronize do 
				cache_key = _cache_key(handler, query)
				if @config.cache.include? cache_key then
					rdebug "request in cache %s, %s" % [handler, query]
					# send result from cache
					result = @config.cache[cache_key]

				elsif @queue.include? handler, query then
					rdebug "request in queue %s, %s" % [handler, query]
					# you'll have to wait
					result = nil
				else
					rdebug "request nowhere %s, %s" % [handler, query]
					# neither in cache nor in queue
					# we add request to the queue
					priority = case mode 
							   when MODE_INTERACTIVE then 5
							   when MODE_PASSIVE then 1
							   else 1
							   end
					@queue.push handler, query, priority
					result = nil
				end
			end
			return result
		end


		# no need to be synchronized
		def handle req
			case req.handler
			when REQUEST_EXPECTED then 
				# do something
			else
				STDOUT.puts "unknown handler for %s" % req.inspect
			end
		end


		# no need to be synchronized
		def run
			Thread.abort_on_exception = true
			Thread.new do
				rdebug 'crawler up and running!'
				while true
					rdebug 'loop start (sleep)'
					sleep 1
					# get first in queue, by priority
					rdebug 'queue first'
					req = @queue.first
					next if req.nil?

					rdebug 'handling %s' % req.inspect
					# call proper handler for request
					#handle next_req

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
	end

end

