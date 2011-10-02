
require 'thread'

require 'vocabularise/crawler_queue'
require 'vocabularise/hit_counter'

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

			# FIXME: add multiple crawling threads for more efficiency
			# or to prevent blocked requests
		end


		# request a request
		def request handler, query, mode
			priority = case mode 
					   when MODE_INTERACTIVE then 5
					   when MODE_PASSIVE then 1
					   else 1
					   end
			@queue.push handler, query, priority
		end

		# 
		def handle req
			case req.handler
			when REQUEST_EXPECTED then 
				# do something
			else
				STDOUT.puts "unknown handler for %s" % req.inspect
			end
		end

		def run
			Thread.abort_on_exception = true
			Thread.new do
				STDERR.puts "crawler up and running!"
				while true
					sleep 1
					# get first in queue, by priority
					req = @queue.first
					next if req.nil?

					pp req
					# call proper handler for request
					#handle next_req

					@queue.shift
				end
			end
		end
	end

end

