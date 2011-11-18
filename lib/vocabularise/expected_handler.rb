
require 'vocabularise/request_handler'
require 'vocabularise/internal_handler'

module VocabulariSe
	#
	#

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
				# sum of views for all documents                                
				views = 1                                                       
				apparitions = reltag_count                                      

				limit = 1                                                       

				related_documents = @crawler.request \
					HANDLE_INTERNAL_RELATED_DOCUMENTS, 
					{"tag_list" => [intag, reltag]}

				rdebug "related docs to [%s,%s] : %s" % [ intag, reltag, related_documents.inspect ]

				related_documents.each do |doc|
					views += doc.readers            
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
