
require 'vocabularise/request_handler'

require 'vocabularise/internal_handler'

module VocabulariSe

	HANDLE_INTERNAL_AGGREGATING = "internal:aggregating"

	class InternalAggregating < RequestHandler

		handles HANDLE_INTERNAL_AGGREGATING
		no_cache_result

		process do |handle, query, priority|

			@crawler.request \
				HANDLE_INTERNAL_RELATED_TAGS,
				{ :query => @query }

			@debug = true
			rdebug "hello world"
			STDERR.puts "hello world 2"
		end
	end

end
