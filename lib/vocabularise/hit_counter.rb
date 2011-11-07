
require 'rdebug/base'
require 'monitor'

module VocabulariSe

	# A request item, should correspond to exactly one API hit

	# FIXME: store hit counter in database & use timestamps
	# FIXME: if time > next_timestamp => do not wait (but set next timestamp)
	# FIXME: if time <= next_timestmap => wait for the time difference
	
	class HitCounter

		def initialize
			@monitor = Monitor.new
			@counter = {}
			@limit = {}
			@debug = true
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
			raise ArgumentError unless @counter.include? ns
			@monitor.synchronize do
				@counter[ns]+= 1 
				@counter[ns] = 0 if @counter[ns] >= @limit[ns]
			end
			rdebug "counting a hit for %s" % ns
			sleep (3600.0 / @limit[ns])
		end
	end

end

