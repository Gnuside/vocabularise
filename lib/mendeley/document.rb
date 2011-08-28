
module Mendeley
	class Document

		DOCUMENTS_TAGGED_LIMIT = 5

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
			cached = true
			cached &&= @short_json["x-cache-used"]
		   	cached &&= @long_json["x-cache-used"] unless @long_json.nil?
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
				resp = client.documents_tagged({
				   	:tag => tag, 
					:page => page 
			#		:limit => DOCUMENTS_TAGGED_LIMIT 
				})
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
