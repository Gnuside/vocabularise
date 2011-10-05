
require 'dm-core'
require 'dm-validations'

module VocabulariSe
	# a queue entry
	class CrawlerQueueEntry
		include DataMapper::Resource

		property :id, Serial
		property :cquery,   String, :length => 200, :unique_index => :u1
		property :handler, String, :length => 200, :unique_index => :u1
		property :priority, Integer, :default => 0
		property :created_at, Integer, :required => true

		validates_uniqueness_of :cquery, :scope => :handler
	end

	class CacheEntry
		include DataMapper::Resource

		property :id,   String, :length => 200, :key => true
		property :created_at, Integer, :required => true                        
		property :expires_at, Integer, :required => true                        

		has n, :cache_chunks
	end

	class CacheChunk
		include DataMapper::Resource

		property :id, Serial
		property :part, Integer, :required => true 
		property :data, Text, :required => true 

		belongs_to :cache_entry
	end
end
