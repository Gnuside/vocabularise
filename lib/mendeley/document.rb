
module Mendeley
	class Document

		# Instance
		#
		def initialize json
			@json = json
		end

		# Instance
		#
		def title 
			@json["title"]
		end

		# Instance
		#
		def uuid
			@json["uuid"]
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
