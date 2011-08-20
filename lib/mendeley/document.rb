
module Mendeley
	class Document

		# Instance
		#
		def initialize json
			# FIXME detect what json it is
			@short_json = json
			@long_json = nil
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
			@short_json["title"]
		end

		# Instance
		#
		def uuid
			@short_json["uuid"]
		end

		def cached?
			@short_json["x-cache-used"] || @long_json["x-cache-used"]
		end

		# tags
		#
		def tags client
			self.details client if @long_json.nil?
			@long_json["tags"].to_a
		end

		def details client
			@long_json = client.documents_details( :id => self.uuid )
		end

		# Static
		#
		def self.search_tagged client, tag, &blk
			page = 0
			total_pages = 0
			while true do
				resp = client.documents_tagged( :tag => tag, :page => page )
				total_pages = resp["total_pages"]
				if resp["documents"].nil? then pp resp end
				resp["documents"].each do |resp_doc|
					doc = Document.new resp_doc
					yield doc
				end
				page += 1
				break if page >= total_pages
			end
		end
	end
end
