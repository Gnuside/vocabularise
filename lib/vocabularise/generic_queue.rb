
module VocabulariSe
	class GenericQueue 	
		include Enumerable
		# FIXME: do something for priority

		def initialize
			raise NotImplementedError
		end

		def include? key
			raise NotImplementedError
		end

		def []= key, resp
			raise NotImplementedError
		end

		def [] key
			raise NotImplementedError
		end

		def each &blk
			raise NotImplementedError
		end
	end
end
