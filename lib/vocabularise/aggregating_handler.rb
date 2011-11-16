
require 'vocabularise/request_handler'

require 'vocabularise/internal_handler'

module VocabulariSe

	HANDLE_INTERNAL_AGGREGATING = "internal:aggregating"

	class InternalAggregating < RequestHandler

		handles HANDLE_INTERNAL_AGGREGATING
		cache_result

		process do |handle, query, priority|

			@crawler.request \
				HANDLE_INTERNAL_RELATED_TAGS,
				{ "query" => @query }

			raise NotImplementedError
		end
	end

end
