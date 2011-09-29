
require 'pp'
require 'monitor'

require 'vocabularise/utils'
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
			key = _key(action, intag)
			result = nil
			@monitor.synchronize do 
				if @config.cache.include? key then
					STDERR.puts "request in cache %s, %s" % [action, intag]
					# send result from cache
					result = @config.cache[key]
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
					#Thread.abort_on_exception = true
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

		def queue action, intag
			@monitor.synchronize do 
				@queue << _key(action, intag)
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
			#begin
			
			STDERR.puts "request begin-run %s, %s" % [action, intag]
			key = _key(action, intag)
			result = nil
			case action
			when REQUEST_RELATED then
				result = VocabulariSe::Utils.related_tags @config, intag
				#puts "handler - related tags for %s" % key
				#pp result

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
			@config.cache[key] = result
			STDERR.puts "request end-run %s, %s" % [action, intag]

			#rescue Exception => e
			#	STDERR.puts e.message
			#	STDERR.puts e.backtrace
			#end
		end

		private

		def _key action, intag
			key = "%s:%s" % [action,intag]	
		end
	end
end

