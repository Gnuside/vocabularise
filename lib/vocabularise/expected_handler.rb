
require 'vocabularise/request_handler'
require 'vocabularise/internal_handler'

module VocabulariSe
	#
	#

	LIMIT_DOCUMENTS_PER_TAGREL = 10

	HANDLE_INTERNAL_EXPECTED = "internal:expected"

	class InternalExpected < RequestHandler

		handles HANDLE_INTERNAL_EXPECTED
		cache_result DURATION_SHORT

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			intag = query['tag']

			related_tags = @crawler.request HANDLE_INTERNAL_RELATED_TAGS,
				{ "tag" => intag }

			workspace = {}
			documents = Set.new

			# for each related tag,
			# look for documents related to both initial & related tag
			# then compute slope for each document
			related_tags.each do |reltag,reltag_count|
				ws_tag = {
					:links => [],
					:views => 0,
					:apparitions => 0,
					:slope => 0
				}

				# sum of views for all documents
				views = 1
				apparitions = reltag_count

				limit = 1
				related_documents = @crawler.request \
					HANDLE_INTERNAL_RELATED_DOCUMENTS,
					{"tag_list" => [intag, reltag], "limit" => LIMIT_DOCUMENTS_PER_TAGREL }

				# skip current tag if no related documents
				next if related_documents.nil?

				rdebug "related docs to [%s,%s] : %s" % [ intag, reltag, related_documents.inspect ]

				related_documents.each do |doc|
					ws_tag[:links] << { 
						:url => doc.url, 
						:text => (
							if doc.title.size > 27 then doc.title[0..27] + "..."
							else doc.title 
							end )
					}

					views += doc.readers
				end
				slope =  apparitions.to_f / views.to_f

				ws_tag.merge!({
					:views => views,
					:apparitions => apparitions,
					:slope => slope
				})
				workspace[reltag] = ws_tag
			end

			# sort workspace keys (tags) by increasing slope
			result = workspace.sort{ |a,b| a[1][:slope] <=> b[1][:slope] }.reverse

			return result
		end
	end
end
