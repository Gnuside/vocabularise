
require 'dm-core'

module VocabulariSe

	# A request item, corresponding to exactly one API hit
	class RequestItem
		include DataMapper::Ressource

		property :id, Serial

		# handler type
		# ex: Mendeley/Document/:id
		# ex: Mendeley/Tag/Page/...
		# ex: Mendeley/
		property :handler, String, :required => true
		property :url, String, :required => true, :unique => true

		# depending on type, the larger results, the lesser priority
		# (treat documents first...)
		# ex: Mendeley/Document => 3
		# ex: Mendeley/Tag => 2
		# ex: Wikipedia/Search => 1
		property :priority, Integer, :required => true

		# when request is created
		property :created_at, Integer, :required => true
	end
end

