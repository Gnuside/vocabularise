
require 'lib/vocabularise/generic_algorithm'

module VocabulariSe
	class ExpectedAlgorithm < GenericAlgorithm

		def exec intag, related_tags

			# Association audacieuse
			workspace = {}
			documents = Set.new

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

				hit_count = 0
				limit = 1
				VocabulariSe::Utils.related_documents_multiple config, [intag, reltag] do |doc|
					views += doc.readers(config.mendeley_client)
					ws_tag[:links] << { 
						:url => doc.url, 
						:text => (
							if doc.title.size > 27 then doc.title[0..27] + "..."
							else doc.title 
							end )
					}

					# limit to X real hits
					hit_count += 1 unless doc.cached?
					#puts "AlgoI - hit_count = %s" % hit_count
					break if hit_count > limit
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
