
require 'monitor'

module VocabulariSe

	# A request item, should correspond to exactly one API hit

	class HitCounter

		def initialize
			@monitor = Monitor.new
			@counter = {}
			@limit = {}
		end


		# set hit limits for given namespace
		#
		# ex: 
		#  hc = HitCounter.new
		#  hc.limit :mendeley, 500
		#
		def limit ns, max_per_hour
			@monitor.synchronize do
				@counter[ns] = 0
				@limit[ns] = max_per_hour
			end
		end


		# count a new hit and sleep required amount of time
		# for given namespace
		#
		def hit ns
			@monitor.synchronize do
				@counters[ns]+= 1 
				@counters[ns] = 0 if @counters[ns] >= @limit[ns]
			end
			sleep (3600.0 / max_per_hour)
		end
	end

end

