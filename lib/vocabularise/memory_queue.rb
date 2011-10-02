
require 'vocabularise/generic_queue'

module VocabulariSe
	class MemoryQueue < GenericQueue

		def initialize
			@queue = []
			@content = {}
		end

		def include? key
			@queue.include? key
		end

		def []= key, data
			@queue << key
			@content[key] = data
		end

		def [] key
			@content[key]	
		end

		def each &blk
			@queue.each do |x|
				yield x
			end
		end

		def << key
			@queue << key
			@content[key] = nil
		end
	end
end

