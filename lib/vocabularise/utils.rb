
require 'set'
require 'mendeley'

require 'rubygems'
require 'wikipedia'

module VocabulariSe
	class Utils

		class RelatedTagsFailure < ArgumentError ; end

		RELATED_TAGS_DEFAULT_HITLIMIT = 5
		RELATED_DOCUMENTS_DEFAULT_HITLIMIT = 5

		@@debug = true
		@debug = true

		#
		# Return an array of related documents for given input tag
		#
		def self.related_documents config, intag, limit=RELATED_DOCUMENTS_DEFAULT_HITLIMIT, &blk
			rdebug "VocabulariSe::Utils.related_documents config, %s" % intag
			documents = Set.new
			hit_count = 0
			begin
				Mendeley::Document.search_tagged config.mendeley_client, intag do |doc|
					raise RuntimeError, "nil document" if doc.nil?
					raise RuntimeError, "nil document" if doc.kind_of? Array
					if block_given? then
						pp doc if @debug or @@debug ;
						yield doc 
					end
					documents.add doc

					hit_count += 1 unless doc.cached?
					rdebug "hit_count = %s" % hit_count
					break if hit_count > limit
				end
			rescue Mendeley::Client::RateLimitExceeded
				# try to survive
			end
			return documents
		end


		#
		#
		#
		def self.related_documents_multiple config, intag_arr, limit=RELATED_DOCUMENTS_DEFAULT_HITLIMIT, &blk
			rdebug "config, [%s]" % intag_arr.join(', ')
			head = intag_arr[0]
			tail_arr = intag_arr[1..-1]

			# for head
			head_documents = Set.new
			tail_documents = Set.new

			head_limit = limit.to_f / intag_arr.size.to_f
			tail_limit = tail_arr.size.to_f * head_limit

			# FIXME: hit count = #tags * #limit => that makes a lot
			
			# for tail
			unless tail_arr.empty? then
				tail_documents = self.related_documents_multiple config, tail_arr, tail_limit
				#head_documents.intersection tail_documents 
			end
			self.related_documents config, head, head_limit do |doc|
				if not tail_documents.include? doc then
					yield doc if block_given?
					#pp doc
					head_documents.add doc
				end
			end

			return head_documents.to_a
		end
		

		# Return an hash of related tags with associated occurencies 
		# for given input tag
		def self.related_tags config, intag, algo=:default, limit=RELATED_TAGS_DEFAULT_HITLIMIT
			# set count to zero
			tags = Hash.new 0

			case algo
			when :default then
				# try mendeley
				if tags.empty? 
					mendeley_related = related_tags config, intag, :mendeley
					tags.merge!( mendeley_related ) do |key,oldval,newval|
						oldval + newval
					end
				end
				# try wikipedia
				if tags.empty? 
					wikipedia_related = related_tags config, intag, :wikipedia
					tags.merge!( wikipedia_related ) do |key,oldval,newval|
						oldval + newval
					end
				end
				# or fail
				
			when :mendeley then
				# get tags from documents
				
				begin
					hit_count = 0
					# using the API
					Mendeley::Document.search_tagged config.mendeley_client, intag do |doc|
						document_tags = doc.tags config.mendeley_client
						rdebug "Merge document tags"
						rdebug "common tags : %s" % tags.inspect
						rdebug "   doc tags : %s" % document_tags.inspect
						document_tags.each do |tag|
							words = tag.split(/\s+/)
							if words.length > 1 then
								words.each { |w| tags[w] += 1 }
							else
								tags[tag] += 1
							end
						end
						rdebug "merged tags : %s" % tags.inspect

						hit_count += 1 unless doc.cached?
						rdebug "hit_count = %s" % hit_count
						break if hit_count > limit
					end
				rescue Mendeley::Client::RateLimitExceeded => e
					# try to resist ;-)
				end

				# remove tags with non alpha characters
				tags.keys.each do |tag|
					tags.delete(tag) if tag.strip =~ /:/ ;
				end

				# using scrapping
				#Mendeley::
				#doc = Nokogiri::HTML(open('http://

			when :wikipedia then
				page_json = config.wikipedia_client.request_page intag
				page = Wikipedia::Page.new page_json
				page.links.each { |tag| tags[tag] += 1 }

			else # :fail :-(
				raise RelatedTagsFailure

			end

			tags.delete(intag)
			rdebug "result tags = %s" % tags.inspect
			return tags
		end 

	end # class
end # module
