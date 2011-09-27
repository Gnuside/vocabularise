
require 'lib/vocabularise/generic_algorithm'

module VocabulariSe
	class ExceptedAlgorithm < GenericAlgorithm

		def exec tag
			puts "Algo I"
			print "tag ? "
			intag = STDIN.gets.strip

			Indent.more

			# Association audacieuse
			workspace = {}
			documents = Set.new
			related_tags = VocabulariSe::Utils.related_tags config, intag

			puts "AlgoI - related tags :"
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
					puts "AlgoI - hit_count = %s" % hit_count
					break if hit_count > limit
				end
				slope =  apparitions.to_f / views.to_f
				workspace[reltag] = {
					:views => views,
					:apparitions => apparitions,
					:slope => slope
				}
			end

			puts "AlgoI - workspace tags :"
			pp workspace.keys

			# sort workspace keys (tags) by increasing slope 
			result = workspace.sort{ |a,b| a[1][:slope] <=> b[1][:slope] }.reverse

			# FIXME : limit to 3 or 5 results only
			puts "AlgoI - result :"
			pp result[0..4]

			pp JSON.generate(result[0..4])
		end

	end
end
