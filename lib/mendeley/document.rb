
require 'common/indent'
require 'mendeley/cache'

module Mendeley
	class Document

		DOCUMENTS_TAGGED_LIMIT = 5

		# Instance
		#
		def initialize json
			# FIXME detect what json it is
			@short_json = json
			@long_json = nil
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

		def cached?
			#puts "short_json cached = %s" % @short_json[JSON_CACHE_KEY]
			cached = @short_json[JSON_CACHE_KEY]

			# replace with long json cache status if loaded
			#puts "long_json cached = %s" % @long_json[JSON_CACHE_KEY] unless @long_json.nil?
		   	cached = @long_json[JSON_CACHE_KEY] unless @long_json.nil?
			rdebug "(%s) %s" % [self.uuid, cached]
			return cached
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


		#
		# return a list of hashes
		# { "name" => ... ; "id" => ... ; "value" => ... }
		#
		def disciplines client
			self.details client if @long_json.nil?
			@long_json["stats"]["discipline"].to_a
		end

		def readers client
			self.details client if @long_json.nil?
			#pp @long_json["stats"]
			@long_json["stats"]["readers"].to_i
		end

		# FIXME: remove hard limit
		DOCUMENTS_TAGGED_PAGE_LIMIT = 10

		#
		# Static
		#
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
	end
end
