
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

		def initialize config
			@config = config
			@queue = CrawlerQueue.new

			# FIXME: add multiple crawling threads for more efficiency
			# or to prevent blocked requests
		end


		# request a request
		def request something, mode
			priority = case mode 
					   when MODE_INTERACTIVE then 5
					   when MODE_PASSIVE then 1
					   else 1
					   end
			@config.queue something, {:priority => priority}
		end

		# 
		def handle req
			case req.handler
			when "FIXME"
				# 
			end
		end

		def run
			Thread.new do
				STDERR.puts "crawler up and running!"
				while true
					# get first in queue, by priority
					next_req = @config.queue.first
					# call proper handler for request
					handle next_req

					@config.queue.shift
				end
			end
		end
	end

end

