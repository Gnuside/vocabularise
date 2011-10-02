
module VocabulariSe
	class GenericCache
		include Enumerable

		def initialize directory, timeout
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
