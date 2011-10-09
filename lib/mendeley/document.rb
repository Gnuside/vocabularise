
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
			@short_json["title"]
		end

		# Instance
		#
		def uuid
			@short_json["uuid"]
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

		# FIXME: remove hard limit
		#DOCUMENTS_TAGGED_PAGE_LIMIT = 10

		#
		# Static
		#
		# search_tagged
		#   * if cached return result
		#   * look for all pages _from cache_
		#   * +request two more pages (search_tagged_page tag, page)
		#   * for cached pages, compute tags on documents
		#   * add computation in cache
		# 
		# search_tagged_callback:
		#
		#
		#
=begin
		def self.search_tagged client, tag, &blk
			page = 0
			total_pages = 0
			documents = []
			while true do
					# first json snippets count as a hit
					# but all following count as cached
					cached = false
					begin
						resp = client.documents_tagged({
							:tag => tag, 
							:page => page 
							#		:limit => DOCUMENTS_TAGGED_LIMIT 
						})
					rescue Mendeley::Client::ClientError => e
						# got no document list
						break
					end
					total_pages = resp["total_pages"]
					if resp["documents"].nil? then
						pp resp 
						next
					end
					resp["documents"].each do |resp_doc|
						resp_doc[JSON_CACHE_KEY] = cached
						doc = Document.new resp_doc
						documents << doc
						yield doc if block_given?
						cached = true
					end
					page += 1
					break if page >= total_pages
					break if page >= DOCUMENTS_TAGGED_PAGE_LIMIT
			end
			return documents
		end
=end
	end
end
