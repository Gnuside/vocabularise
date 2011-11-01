
require 'vocabularise/request_handler'
require 'vocabularise/internal_handler'

module VocabulariSe
	#
	#

	HANDLE_INTERNAL_EXPECTED = "internal:expected"

	class InternalAggregating < RequestHandler

		handles HANDLE_INTERNAL_EXPECTED
		cache_result

		process do |handle, query, priority|
			intag = query[:query]
			related_tags = @crawler.request HANDLE_INTERNAL_RELATED_TAGS, 
				{ :tag => intag }

			raise NotImplementedError

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
					{:query => [intag, reltag]}

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
