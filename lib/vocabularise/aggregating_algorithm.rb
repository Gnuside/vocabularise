
module VocabulariSe
	class AggregatingAlgorithm < GenericAlgorithm

		def exec intag, related_tags
			Indent.more

			# Association audacieuse
			tag_ws = {}

			Hash.new({
				:ref => nil,
				:value => 0,
				:count => 0
			})

			documents = Set.new

			related_tags.each do |reltag,reltag_count|
				# sum of views for all documents
				views = 1
				apparitions = reltag_count

				hit_count = 0
				limit = 2
				# reset discipline ws
				discipline_ws = {}

				links_ws = Set.new

				# ws de disciplines
				begin
					VocabulariSe::Utils.related_documents_multiple config, [intag, reltag] do |doc|
						# list disciplines of the document
						disciplines = doc.disciplines(config.mendeley_client)
						#pp disciplines

						# for each discipline :
						#  * add the % of readers
						#  * increment discipline
						disciplines.each do |disc|
							disc_name = disc["name"].to_s
							disc_id = disc["id"].to_i
							disc_value = disc["value"].to_i
							links_ws << {
								:text =>  disc["name"].to_s,
								:url => "http://www.mendeley.com/%s/" % (disc["name"].to_s.downcase.gsub(/\s+/,'') )
							}

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
				rescue Mendeley::Client::RateLimitExceeded => e
					# we got an error here, but we can continue on next tag
					next
				rescue Mendeley::Client::DeferredRequest => e
					# we got an error here, but we can continue on next tag
					next
				end

				sorted_discipline_ws = discipline_ws.sort do |a,b|
					a_reader_avg = a[1][:value].to_f / a[1][:count].to_f
					b_reader_avg = b[1][:value].to_f / b[1][:count].to_f
					a_reader_avg <=> b_reader_avg
				end.reverse
				if sorted_discipline_ws.size > 0 then
					major_discipline = sorted_discipline_ws[0][0]
					pp sorted_discipline_ws
					puts "major_discipline = %s" % major_discipline
					sorted_discipline_ws.shift
				end

				#  associate to each tag found disciplines
				sorted_discipline_ws.shift
				tag_ws[reltag] = { 
					:links => links_ws.to_a,
					:disc_list => sorted_discipline_ws,
					:disc_count => sorted_discipline_ws.size,
					:disc_sum => sorted_discipline_ws.inject(0){ |acc,x| 
					acc + x[1][:value].to_f / x[1][:count].to_f 
				}.to_i
				}

			end

			puts "AlgoIII - all disciplines :"
			pp tag_ws
			#.keys

			puts "AlgoIII - sorted tags (by count then by sum) :"
			# sort ws keys (tags) by increasing slope 
			result = tag_ws.sort{ |a,b| 
				if a[1][:disc_count] == b[1][:disc_count] then
					a[1][:disc_sum] <=> b[1][:disc_sum]
				else
					a[1][:disc_count] <=> b[1][:disc_count]
				end
			}.reverse
		end

	end
end
