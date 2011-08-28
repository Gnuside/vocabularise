
require 'set'
require 'mendeley'

require 'rubygems'
require 'wikipedia'

module VocabulariSe
	class Utils

		class RelatedTagsFailure < ArgumentError ; end

		# Return an array of related documents for given input tag
		#
		def self.related_documents config, intag, &blk
			puts "VocabulariSe::Utils.related_documents config, %s" % intag
			documents = Set.new
			Mendeley::Document.search_tagged config.mendeley_client, intag do |doc|
				if block_given? then
					pp doc
					yield doc 
				end
				documents.add doc
			end
			puts "finish"
			return documents
		end

		def self.related_documents_multiple config, intag_arr, &blk
			puts "VocabulariSe::Utils.related_documents_multiple config, [%s]" % intag_arr.join(', ')
			head = intag_arr[0]
			tail_arr = intag_arr[1..-1]

			# for head
			head_documents = Set.new
			tail_documents = Set.new

			# for tail
			unless tail_arr.empty? then
				tail_documents = self.related_documents_multiple config, tail_arr
				#head_documents.intersection tail_documents 
			end
			self.related_documents config, head do |doc|
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
		def self.related_tags config, intag, algo=:default
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
				
				hit_count = 0
				# using the API
				Mendeley::Document.search_tagged config.mendeley_client, intag do |doc|
					document_tags = doc.tags config.mendeley_client
					p "Merge document tags"
					pp tags
					pp document_tags
					document_tags.each do |tag|
						words = tag.split(/\s+/)
						if words.length > 2 then
							words.each { |w| tags[w] += 1 }
						else
							tags[tag] += 1
						end
					end

					hit_count += 1 unless doc.cached?
					break if hit_count > 5
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

			pp tags
			tags.delete(intag)
			return tags
		end 

	end # class
end # module
