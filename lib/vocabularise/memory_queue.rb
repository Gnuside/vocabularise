
require 'vocabularise/generic_queue'
require 'thread'

module VocabulariSe
	class MemoryQueue < GenericQueue

		def initialize
			@queue = Queue.new
		end

		def << key
			@queue << key
		end

		def include? key
			fake = @queue.clone
			while not fake.empty? do
				if fake.pop == key then
					return true
				end
			end
			return false
		end

		def each &blk
			fake = @queue.clone
			while not fake.empty? do
				yield fake.pop
			end
		end
	end
end

