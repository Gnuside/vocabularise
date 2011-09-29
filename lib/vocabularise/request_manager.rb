
require 'monitor'

require 'vocabularise/expected_algorithm'
require 'vocabularise/controversial_algorithm'
require 'vocabularise/aggregating_algorithm'


module VocabulariSe

	class RequestManager

		REQUEST_RELATED = :related
		REQUEST_EXPECTED = :expected
		REQUEST_CONTROVERSIAL = :controversial
		REQUEST_AGGREGATING = :aggregating

		def initialize config
			@config = config
			@monitor = Monitor.new
			@queue = []

			@algo_expected = VocabulariSe::ExpectedAlgorithm.new config
			@algo_controversial = VocabulariSe::ControversialAlgorithm.new config
			@algo_aggregating = VocabulariSe::AggregatingAlgorithm.new config
		end

		# try to answer to API needs
		def request action, intag
			result = nil
			@monitor.synchronize do 
				if self.in_cache? action, intag then
					STDERR.puts "request in cache %s, %s" % [action, intag]
					# FIXME: send result from cache
					result = [
					   [ :tag1, "toto" ],
					   [ :tag2, "toto" ],
					   [ :tag3, "toto" ]
					]
				elsif self.in_queue? action, intag then
					STDERR.puts "request in queue %s, %s" % [action, intag]
					# you'll have to wait
					result = nil
				else
					STDERR.puts "request nowhere %s, %s" % [action, intag]
					# neither in cache nor in queue
					# we add request to the queue
					self.queue action, intag
					# FIXME: run thread to make request & unqueue
					Thread.abort_on_exception = true
					Thread.new do
						# do nothing
						self.handle action, intag
						self.unqueue action, intag
					end
					result = nil
				end
			end
			return result
		end


		def in_queue? action, intag
			@monitor.synchronize do 
				@queue.include? _key(action, intag)
			end
		end

		def in_cache? action, intag
			@monitor.synchronize do 

			end
		end

		def queue action, intag
			@monitor.synchronize do 
				@queue << _key(action, intag)
			end
		end

		def cache action, intag, result
			@monitor.synchronize do 
			# FIXME : store the result in cache
			end
		end

		def unqueue action, intag
			key = _key(action, intag)
			@monitor.synchronize do 
				@queue = @queue.select do |x|
					x != key
				end
			end
		end

		# stop (return) if not computable (missing prerequisites, etc)
		def handle action, intag
			STDERR.puts "request begin-run %s, %s" % [action, intag]
			result = nil
			case action
			when REQUEST_RELATED then
				result = VocabulariSe::Utils.related_tags config, intag                   
			when REQUEST_EXPECTED then
				related_tags = request REQUEST_RELATED, intag
				return if related_tags.nil?
				result = @algo_expected.exec intag, related_tags 

			when REQUEST_CONTROVERSIAL then
				related_tags = request REQUEST_RELATED, intag
				return if related_tags.nil?
				result = @algo_controversial.exec intag, related_tags 

			when REQUEST_AGGREGATING then
				related_tags = request REQUEST_RELATED, intag
				return if related_tags.nil?
				result = @algo_aggregating.exec intag, related_tags 

			else
				raise RuntimeError, "unknown action"
			end
			STDERR.puts "request end-run %s, %s" % [action, intag]
			cache action, intag, result
		end

		private

		def _key action, intag
			key = "%s:%s" % [action,intag]	
		end
	end
end

