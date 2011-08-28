
require 'set'
require 'mendeley'

require 'rubygems'
require 'wikipedia'

module VocabulariSe
	class Utils

		class RelatedTagsFailure < ArgumentError ; end

		RELATED_TAGS_DEFAULT_HITLIMIT = 5
		RELATED_DOCUMENTS_DEFAULT_HITLIMIT = 5

		#
		# Return an array of related documents for given input tag
		#
		def self.related_documents config, intag, limit=RELATED_DOCUMENTS_DEFAULT_HITLIMIT, &blk
			puts "VocabulariSe::Utils.related_documents config, %s" % intag
			documents = Set.new
			hit_count = 0
			Mendeley::Document.search_tagged config.mendeley_client, intag do |doc|
				raise RuntimeError, "nil document" if doc.nil?
				raise RuntimeError, "nil document" if doc.kind_of? Array
				if block_given? then
					pp doc
					yield doc 
				end
				documents.add doc

				hit_count += 1 unless doc.cached?
				puts "hit_count = %s" % hit_count
				break if hit_count > limit
			end
			puts "finish"
			return documents
		end


		#
		#
		#
		def self.related_documents_multiple config, intag_arr, limit=RELATED_DOCUMENTS_DEFAULT_HITLIMIT, &blk
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
		

		#
		# Return an array of related tags for given input tag
		#
		def self.related_tags config, intag, algo=:default, limit=RELATED_TAGS_DEFAULT_HITLIMIT
			tags = Set.new

			case algo
			when :default then
				# try mendeley
				tags.merge( related_tags config, intag, :mendeley ) if tags.empty? 
				# try wikipedia
				tags.merge( related_tags config, intag, :wikipedia ) if tags.empty?
				# or fail
				
			when :mendeley then
				# get tags from documents
				
				hit_count = 0
				# using the API
				Mendeley::Document.search_tagged config.mendeley_client, intag do |doc|
					tags.merge( doc.tags config.mendeley_client )

					hit_count += 1 unless doc.cached?
					puts "hit_count = %s" % hit_count
					break if hit_count > limit
				end

				# using scrapping
				#Mendeley::
				#doc = Nokogiri::HTML(open('http://

			when :wikipedia then
				page_json = config.wikipedia_client.request_page intag
				page = Wikipedia::Page.new page_json
				tags = pp page.links

			else # :fail :-(
				raise RelatedTagsFailure

			end

			return (tags - [intag]).to_a
		end 

	end # class
end # module
