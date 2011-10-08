
require 'vocabularise/config'
require 'rdebug/base'
require 'mendeley/cache'
require 'cgi'

require 'vocabularise/request_handler'

module Mendeley ; class Client 
		class DeferredRequest < ::Mendeley::Client::ClientError ; end
end ; end


module VocabulariSe ; module MendeleyExt

	module DeferredRequest

		REQUEST_STATS_AUTHORS = "mendeley:stats_authors"
		REQUEST_STATS_PAPERS = "mendeley:stats_papers"
		REQUEST_STATS_PUBLICATIONS = "mendeley:stats_publications"
		REQUEST_STATS_TAGS = "mendeley:stats_tags"
		REQUEST_DOCUMENTS_SEARCH = "mendeley:documents_search"
		REQUEST_DOCUMENTS_DETAILS = "mendeley:documents_details"
		REQUEST_DOCUMENTS_TAGGED = "mendeley:documents_tagged"

		attr_accessor :crawler


		#
		#
		def initialize consumer_key, crawler
			super consumer_key

			@crawler = crawler
			@debug = true
		end


		#
		#
		#
		def stats_authors params
			begin
				@crawler.request REQUEST_STATS_AUTHORS, params
			rescue VocabulariSe::Crawler::DeferredRequest => e
				raise ::Mendeley::Client::DeferredRequest, "stats_authors"
			end
		end


		#
		#
		#
		def stats_papers params                                                                                         
			begin
				@crawler.request REQUEST_STATS_PAPERS, params
			rescue VocabulariSe::Crawler::DeferredRequest => e
				raise ::Mendeley::Client::DeferredRequest, "stats_papers"
			end
		end


		#
		#
		#
		def stats_publications params                                                                                   
			begin
				@crawler.request REQUEST_STATS_PUBLICATIONS, params
			rescue VocabulariSe::Crawler::DeferredRequest => e
				raise ::Mendeley::Client::DeferredRequest, "stats_publications"
			end
		end


		#
		#
		#
		def stats_tags params                                                                                           
			begin
				@crawler.request REQUEST_STATS_TAGS, params
			rescue VocabulariSe::Crawler::DeferredRequest => e
				raise ::Mendeley::Client::DeferredRequest, "stats_tags"
			end
		end

		#
		#
		#
		def documents_search params                                                                                     
			begin
				@crawler.request REQUEST_DOCUMENTS_SEARCH, params
			rescue VocabulariSe::Crawler::DeferredRequest => e
				raise ::Mendeley::Client::DeferredRequest, "documents_search"
			end
		end

		#
		#
		#
		def documents_details params                                                                                    
			begin
				@crawler.request REQUEST_DOCUMENTS_DETAILS, params
			rescue VocabulariSe::Crawler::DeferredRequest => e
				raise ::Mendeley::Client::DeferredRequest, "documents_details"
			end
		end

		#
		#
		#
		def documents_tagged params                                                                                     
			begin
				@crawler.request REQUEST_DOCUMENTS_TAGGED, params
			rescue VocabulariSe::Crawler::DeferredRequest => e
				raise ::Mendeley::Client::DeferredRequest, "documents_tagged"
			end
		end

	end
end ; end
