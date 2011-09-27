
module VocabulariSe
	class GenericAlgorithm
		attr_reader :config

		def initialize config
			@config = config
		end

		def exec tag
			raise NotImplementedError
		end
	end
end
