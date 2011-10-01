
require 'vocabularise/generic_cache'

module VocabulariSe
	class DatabaseCache < GenericCache

		def initialize directory, timeout
		end

		def include? key
		end

		def []= key, resp
		end

		def [] key
		end

		def each &blk
		end
	end
end
