
require 'vocabularise/request_handler'

module VocabulariSe

	HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED = "mendeley:document:search_tagged"
	HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE = "mendeley:document:search_tagged:page"
	HANDLE_MENDELEY_DOCUMENT_DETAILS = "mendeley:document:details"

	class MendeleyDocumentSearchTagged < RequestHandler
		handles HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED
		cache_result

		process do |handle, query, priority|
			@debug = true
			handle_str = "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			rdebug handle_str

			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			tag = query['tag']

			page = 0                                                            
			total_pages = 0                                                     
			deferred_counter = 0
			pages = []
			documents = []                                                      
 
			rdebug "requesting new pages for %s" % handle_str
			# looking for three new pages
			while (deferred_counter < 3) do
				begin
					resp = @crawler.request \
						HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE,
						{ :tag => tag, :page => page }
					pages << resp
				rescue Crawler::DeferredRequest
					deferred_counter += 1
				end
				page += 1
			end
			# but fail if not enough pages are accessible
			raise Crawler::DeferredRequest if pages.size < 1

			rdebug "adding documents for %s" % handle_str
			pages.each do |resp|
				# first json snippets count as a hit                        
				# but all following count as cached                         
				total_pages = resp["total_pages"]                           
				if resp["documents"].nil? then                              
					raise RuntimeError, "got a page with no documents !"
					pp resp                                                 
					next                                                    
				end                                                         
				resp["documents"].each do |doc_json|                        
					doc = Mendeley::Document.new doc_json
					documents << doc                                        
				end                                                         
				page += 1                                                   
				break if page >= total_pages                                
				break if page >= DOCUMENTS_TAGGED_PAGE_LIMIT                
			end                                                                 
			return documents
		end
	end


	#
	# Request a page and all of its documents
	#
	class MendeleyDocumentSearchTaggedPage < RequestHandler
		handles HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE
		cache_result

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]

			raise ArgumentError, "no 'tag' found" unless query.include? "tag"
			tag = query["tag"]

			raise ArgumentError, "no 'page' found" unless query.include? "page"
			page = query["page"]

			# make the request
			resp = @config.mendeley_client.documents_tagged({  
				:tag => tag,                                        
				:page => page                                       
				#       :limit => DOCUMENTS_TAGGED_LIMIT            
			})                                                      
			documents = []
			resp["documents"].each do |resp_doc|                        
				# FIXME: request document...
				doc_json = @crawler.request \
					HANDLE_MENDELEY_DOCUMENT_DETAILS,
					{ :uuid => resp_doc["uuid"] }
				documents << doc_json
			end
			resp["documents"] = documents
			return resp
		end
	end



	class MendeleyDocumentDetails < RequestHandler
		handles HANDLE_MENDELEY_DOCUMENT_DETAILS
		cache_result

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]

			raise ArgumentError, "no 'uuid' found" unless query.include? 'uuid'
			uuid = query['uuid']

			resp = @config.mendeley_client.documents_details( :id => uuid )
		end
	end
end
