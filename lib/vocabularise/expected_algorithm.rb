
require 'lib/vocabularise/generic_algorithm'

module VocabulariSe
	class ExpectedAlgorithm < GenericAlgorithm

		def exec intag, related_tags

			# Association audacieuse
			workspace = {}
			documents = Set.new

			#puts "AlgoI - related tags :"
			related_tags.each do |reltag,reltag_count|
				# sum of views for all documents
				views = 1
				apparitions = reltag_count

				hit_count = 0
				limit = 1
				VocabulariSe::Utils.related_documents_multiple config, [intag, reltag] do |doc|
					views += doc.readers(config.mendeley_client)

					# limit to X real hits
					hit_count += 1 unless doc.cached?
					#puts "AlgoI - hit_count = %s" % hit_count
					break if hit_count > limit
				end
				slope =  apparitions.to_f / views.to_f
				workspace[reltag] = {
					:views => views,
					:apparitions => apparitions,
					:slope => slope
				}
			end

			# sort workspace keys (tags) by increasing slope 
			result = workspace.sort{ |a,b| a[1][:slope] <=> b[1][:slope] }.reverse

			return result
		end

	end
end
