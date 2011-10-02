
require 'dm-core'
require 'vocabularise/generic_cache'

module VocabulariSe

	class DatabaseCacheEntry
		include DataMapper::Resource

		property :id,   String, :key => true
		property :data, String, :required => true 
		property :created_at, Integer, :required => true                        
		property :expires_at, Integer, :required => true                        

	end

	class DatabaseCache < GenericCache

		def initialize directory, timeout
			super
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
