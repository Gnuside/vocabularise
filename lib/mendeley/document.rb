
require 'common/indent'
require 'mendeley/cache'

module Mendeley
	class Document

		DOCUMENTS_TAGGED_LIMIT = 5

		# Instance
		#
		def initialize long_json
			@long_json = long_json
			@debug = false
		end

		def hash
			self.uuid.hash
		end

		# Instance
		#
		def == doc
			return self.uuid == doc.uuid
		end

		# Instance
		#
		def title 
			@long_json["title"]
		end

		# Instance
		#
		def uuid
			@long_json["uuid"]
		end

		# tags
		#
		def tags
			@long_json["tags"].to_a
		end

		#
		# return a list of hashes
		# { "name" => ... ; "id" => ... ; "value" => ... }
		#
		def disciplines
			@long_json["stats"]["discipline"].to_a
		end

		def readers
			#pp @long_json["stats"]
			@long_json["stats"]["readers"].to_i
		end

	end
end
