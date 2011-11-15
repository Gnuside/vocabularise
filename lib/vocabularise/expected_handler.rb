
require 'vocabularise/request_handler'
require 'vocabularise/internal_handler'

module VocabulariSe
	#
	#

	HANDLE_INTERNAL_EXPECTED = "internal:expected"

	class InternalAggregating < RequestHandler

		handles HANDLE_INTERNAL_EXPECTED
		cache_result DURATION_SHORT

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			intag = query['tag']

			related_tags = @crawler.request HANDLE_INTERNAL_RELATED_TAGS, 
				{ :tag => intag }

			# Association audacieuse                                            
			workspace = {}                                                      
			documents = Set.new   

			related_tags.each do |reltag,reltag_count|                          
				# sum of views for all documents                                
				views = 1                                                       
				apparitions = reltag_count                                      

				hit_count = 0                                                   
				limit = 1                                                       

				related_documents = @crawler.request \
					HANDLE_INTERNAL_RELATED_DOCUMENTS, 
					{:tag_list => [intag, reltag]}

				related_documents.each do |doc|
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
