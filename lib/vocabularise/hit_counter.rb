
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
			@limit = {}
			@timeout = {}
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
				@timeout[ns] = Time.now.to_i
				@limit[ns] = max_per_hour
			end
		end


		# count a new hit and sleep required amount of time
		# for given namespace
		#
		def hit ns
			raise ArgumentError unless @timeout.include? ns
			raise ArgumentError unless @limit.include? ns
			now = Time.now.to_i
			diff = 0
			@monitor.synchronize do
				diff = @timeout[ns] - now
				@timeout[ns] += (3600.0 / @limit[ns])
			end

			if diff > 0 then
				rdebug "slow (sleep %s) hit for %s" % [ diff, ns ]
				sleep (diff + 1)
			else
				rdebug "fast hit for %s" % ns
			end
		end
	end

end

