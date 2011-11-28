
require 'vocabularise/request_handler'

module VocabulariSe
	#
	#
	HANDLE_WIKIPEDIA_REQUEST_PAGE = "wikipedia:request_page"
	HANDLE_WIKIPEDIA_SEARCH = "wikipedia:search"

	class WikipediaRequestPage < RequestHandler
		handles HANDLE_WIKIPEDIA_REQUEST_PAGE
		cache_result DURATION_LONG

		process do |handle, query, priority|
			@debug = true
			handle_str = "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			rdebug handle_str


			raise ArgumentError, "no 'page' found" unless query.include? 'page'
			page = query['page']

			page_json = @config.wikipedia_client.request_page page
			return page_json
		end
	end


	class WikipediaSearch < RequestHandler
		handles HANDLE_WIKIPEDIA_SEARCH
		cache_result DURATION_LONG

		process do |handle, query, priority|
			@debug = true
			handle_str = "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			rdebug handle_str

			raise ArgumentError, "no 'query' found" unless query.include? 'query'
			page = query['query']

			search_json = @config.wikipedia_client.search( search_expr )          
			return search_json
		end
	end
end
