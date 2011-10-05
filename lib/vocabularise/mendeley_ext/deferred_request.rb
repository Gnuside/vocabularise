
require 'vocabularise/config'
require 'rdebug/base'
require 'mendeley/cache'
require 'cgi'

require 'vocabularise/crawler_handler'

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

		class DeferredRequest 
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
		def stat_authors params
			@crawler.request REQUEST_STATS_AUTHORS, params
		end


		#
		#
		#
		def stats_papers params                                                                                         
			@crawler.request REQUEST_STATS_PAPERS, params
		end


		#
		#
		#
		def stats_publications params                                                                                   
			@crawler.request REQUEST_STATS_PUBLICATIONS, params
		end


		#
		#
		#
		def stats_tags params                                                                                           
			@crawler.request REQUEST_STATS_TAGS, params
		end

		#
		#
		#
		def documents_search params                                                                                     
			@crawler.request REQUEST_DOCUMENTS_SEARCH, params
		end

		#
		#
		#
		def documents_details params                                                                                    
			@crawler.request REQUEST_DOCUMENTS_DETAILS, params
		end

		#
		#
		#
		def documents_tagged params                                                                                     
			@crawler.request REQUEST_DOCUMENTS_TAGGED, params
		end

	end
end ; end
