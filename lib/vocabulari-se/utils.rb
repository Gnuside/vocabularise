
require 'set'
require 'mendeley'

require 'rubygems'
require 'wikipedia'

module VocabulariSe
	class Utils

		class RelatedTagsFailure < ArgumentError ; end

		# Return an array of related documents for given input tag
		def self.related_documents config, intag, algo=:default
			head = intag
			tail = []

			if intag.kind_of? Enumerable then
				head = intag[0]
				tail = intag[1..-1]
			end

			# for head
			head_documents = Set.new
			case algo
			when :default then
			when :mendeley then
				# FIXME : what type for result ? (json, document object, document id, other?)
				# FIXME are Mendeley::Document instances comparable ?
				Mendeley::Document.search_tagged config.mendeley_client, intag do |doc|
					pp doc
				end

			when :wikipedia then
			else # :fail :-(
				raise RelatedDocumentFailure
			end

			# for tail
			unless tail.empty? then
				tail_documents = self.related_documents tail, algo
				head_documents.intersection tail_documents 
			end


			return head_documents.to_a
		end
		

		# Return an array of related tags for given input tag
		def self.related_tags config, intag, algo=:default
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
					break if hit_count > 5
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
