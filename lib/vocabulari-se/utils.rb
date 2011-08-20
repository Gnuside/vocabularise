
require 'set'
require 'mendeley'

require 'rubygems'
require 'wikipedia'

module VocabulariSe
	class Utils

		class RelatedTagsFailure < ArgumentError ; end

		# Return an array of related tags for given input tag
		def self.related_tags intag, algo=:default
			tags = Set.new

			case algo
			when :default then
				# try mendeley
				tags.merge( related_tags intag, :mendeley ) if tags.empty? 
				# try wikipedia
				tags.merge( related_tags intag, :wikipedia ) if tags.empty?
				# or fail
				
			when :mendeley then
				# get tags from documents
=begin
				Mendeley::Document.search_tagged client, intag do |doc|
					pp doc
				end
=end

			when :wikipedia then
				client = Wikipedia::Client.new
				page_json = client.request_page intag
				page = Wikipedia::Page.new page_json
				pp page.links
				raise NotImplementedError

			else # :fail :-(
				raise RelatedTagsFailure

			end

			return tags
		end 

	end
end
