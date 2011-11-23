
require 'vocabularise/request_handler'

require 'vocabularise/internal_handler'

module VocabulariSe

	HANDLE_INTERNAL_AGGREGATING = "internal:aggregating"

	class InternalAggregating < RequestHandler

		handles HANDLE_INTERNAL_AGGREGATING
		cache_result DURATION_SHORT

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			intag = query['tag']

			@crawler.request \
				HANDLE_INTERNAL_RELATED_TAGS,
				{ "tag" => intag }

			# Association audacieuse
			tag_ws = {}

			Hash.new({
				:ref => nil,
				:value => 0,
				:count => 0
			})

			documents = Set.new

			related_tags = @crawler.request HANDLE_INTERNAL_RELATED_TAGS,                                               
				{ "tag" => intag }    

			related_tags.each do |reltag,reltag_count|
				# sum of views for all documents
				views = 1
				apparitions = reltag_count

				hit_count = 0
				limit = 2
				# reset discipline ws
				discipline_ws = {}

				# ws de disciplines

				related_documents = @crawler.request \
					HANDLE_INTERNAL_RELATED_DOCUMENTS, 
					{"tag_list" => [intag, reltag]}


				rdebug "related docs to [%s,%s] : %s" % [ intag, reltag, related_documents.inspect ]

				if related_documents.empty? then
					# skip this tag
					next
				end

				related_documents.each do |doc|
					# list disciplines of the document
					disciplines = doc.disciplines
					#pp disciplines

					# for each discipline :
					#  * add the % of readers
					#  * increment discipline
					disciplines.each do |disc|
						disc_name = disc["name"].to_s
						disc_id = disc["id"].to_i
						disc_value = disc["value"].to_i

						discipline_ws[disc_name] ||= { :value => 0, :count => 0 }
						discipline_ws[disc_name][:value] += disc_value
						discipline_ws[disc_name][:count] += 1

						#puts "  * %s " % disc.inspect
						#puts "ws:"
						#pp discipline_ws
					end

					# limit to X real hits
					hit_count += 1 #unless doc.cached?
					puts "Algo - hit_count = %s" % hit_count
					break if hit_count > limit
				end

				sorted_discipline_ws = discipline_ws.sort do |a,b|
					a_reader_avg = a[1][:value].to_f / a[1][:count].to_f
					b_reader_avg = b[1][:value].to_f / b[1][:count].to_f
					a_reader_avg <=> b_reader_avg
				end.reverse

				pp sorted_discipline_ws
				major_discipline = sorted_discipline_ws[0][0]
				pp sorted_discipline_ws
				#puts "major_discipline = %s" % major_discipline

				#  associate to each tag found disciplines
				sorted_discipline_ws.shift
				tag_ws[reltag] = { 
					:disc_list => sorted_discipline_ws,
					:disc_count => sorted_discipline_ws.size,
					:disc_sum => sorted_discipline_ws.inject(0){ |acc,x| 
					acc + x[1][:value].to_f / x[1][:count].to_f 
				}.to_i
				}

			end

			# sort ws keys (tags) by increasing slope 
			result = tag_ws.sort{ |a,b| 
				if a[1][:disc_count] == b[1][:disc_count] then
					a[1][:disc_sum] <=> b[1][:disc_sum]
				else
					a[1][:disc_count] <=> b[1][:disc_count]
				end
			}.reverse

			return result
		end
	end

end
