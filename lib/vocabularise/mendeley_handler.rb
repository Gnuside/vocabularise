
require 'vocabularise/request_handler'

module VocabulariSe


	HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED = "mendeley:document:search_tagged"
	HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE = "mendeley:document:search_tagged:page"
	HANDLE_MENDELEY_DOCUMENT_DETAILS = "mendeley:document:details"

	PRELOADED_PAGES = 5
	REQUIRED_PAGES = 1
	ITEMS_PER_PAGE = 5

	class MendeleyDocumentSearchTagged < RequestHandler

		handles HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED
		cache_result DURATION_NORMAL

		process do |handle, query, priority|
			@debug = true
			handle_str = "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			rdebug handle_str

			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			tag = query['tag']

			page_counter = 0                                                            
			total_pages = 0                                                     
			deferred_counter = 0
			pages = []
			documents = []                                                      
 
			rdebug "requesting new pages for %s" % handle_str
			# looking for three new pages
			while (deferred_counter < PRELOADED_PAGES) do
				begin
					resp = @crawler.request \
						HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE,
						{ "tag" => tag, "page" => page_counter }
					pages << resp
				rescue Crawler::DeferredRequest
					rdebug "pages %s, %s was deferred" % [ tag, page_counter ]
					deferred_counter += 1
				end
				page_counter += 1
			end
			# but fail if not enough pages are accessible
			if pages.size < REQUIRED_PAGES then
				rdebug "not enough pages (=%s)  available for %s" % [ pages.size, handle_str]
				raise Crawler::DeferredRequest
			end

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
			end                                                                 
			return documents
		end
	end


	#
	# Request a page of tagged documents (and all of the documents details)
	#
	class MendeleyDocumentSearchTaggedPage < RequestHandler

		handles HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE
		cache_result DURATION_NORMAL

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]

			raise ArgumentError, "no 'tag' found" unless query.include? "tag"
			tag = query["tag"]

			raise ArgumentError, "no 'page' found" unless query.include? "page"
			page = query["page"]

			# make the request
			rdebug "make the request"
			resp = nil
			begin
				resp = @config.mendeley_client.documents_tagged({  
					"tag" => tag,                                        
					"page" => page,                                       
					"items" => ITEMS_PER_PAGE
				})                                                      
			rescue 
				raise Crawler::HttpError
			end

			rdebug "request ok"
			documents = []
			resp["documents"].each do |resp_doc|                        
				# request the real document
				doc_json = @crawler.request \
					HANDLE_MENDELEY_DOCUMENT_DETAILS,
					{ "uuid" => resp_doc["uuid"] }
				documents << doc_json
			end
			resp["documents"] = documents
			return resp
		end
	end



	# 
	# Request document details by uuid
	#
	class MendeleyDocumentDetails < RequestHandler
		handles HANDLE_MENDELEY_DOCUMENT_DETAILS
		cache_result DURATION_LONG

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]

			raise ArgumentError, "no 'uuid' found" unless query.include? 'uuid'
			uuid = query['uuid']

			begin
				resp = @config.mendeley_client.documents_details( :id => uuid )
				return resp
			rescue 
				raise Crawler::HttpError
			end
		end
	end

end
