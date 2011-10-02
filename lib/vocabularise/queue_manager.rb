
require 'thread'

require 'vocabularise/request_counter'

module VocabulariSe

	class RequestQueue

		MODE_INTERACTIVE = :interactive
		MODE_PASSIVE = :passive

		COUNTER_WIKIPEDIA_RATE = :wikipedia_rate
		COUNTER_WIKIPEDIA_CURRENT = :wikipedia_current

		COUNTER_MENDELEY_RATE = :mendeley_rate
		COUNTER_MENDELEY_CURRENT = :mendeley_current

		def initialize config
			@config = config


			# prepare everything
			@counter = {
				COUNTER_MENDELEY_RATE => (60 * 60) / 500,
				COUNTER_MENDELEY_CURRENT => 0,
				:wikipedia_rate => (60 * 60) / 500,
				:wikipedia => 0
			}

			counter[:wikipedia] = 0
			speed = (60 * 60) / 500
		end

		# make a request
		def request something, mode

		end

		# 
		def handle req
			case req.handler
		end

		def run
			Thread.new do
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

