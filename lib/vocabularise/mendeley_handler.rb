
require 'vocabularise/request_handler'

module VocabulariSe

	HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED = "mendeley:document:search_tagged"
	HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE = "mendeley:document:search_tagged:page"

	class MendeleyDocumentSearchTagged < RequestHandler
		handles HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED
		no_cache_result

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			rdebug "config = %s, crawler = %s" % [ @config, @crawler ]

			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			tag = query["tag"]

			page = 0                                                            
			total_pages = 0                                                     
			deferred_counter = 0
			pages = []
			documents = []                                                      

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
			raise Crawler::DeferredRequest if pages.size < 2

			pages.each do |resp|
				# first json snippets count as a hit                        
				# but all following count as cached                         
				cached = false                                              
				total_pages = resp["total_pages"]                           
				if resp["documents"].nil? then                              
					raise RuntimeError, "got a page with no documents !"
					pp resp                                                 
					next                                                    
				end                                                         
				resp["documents"].each do |resp_doc|                        
					resp_doc[JSON_CACHE_KEY] = cached                       
					doc = Document.new resp_doc                             
					documents << doc                                        
					cached = true                                           
				end                                                         
				page += 1                                                   
				break if page >= total_pages                                
				break if page >= DOCUMENTS_TAGGED_PAGE_LIMIT                
			end                                                                 
			return documents
		end
	end

	class MendeleyDocumentSearchTaggedPage < RequestHandler
		handles HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE
		no_cache_result

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]

			raise ArgumentError, "no 'tag' found" unless query.include? "tag"
			tag = query["tag"]

			raise ArgumentError, "no 'page' found" unless query.include? "page"
			page = query["page"]


			begin                                                       
				# count a hit
				@config.counter.hit :mendeley

				# make the request
				resp = @config.mendeley_client.documents_tagged({  
					:tag => tag,                                        
					:page => page                                       
					#       :limit => DOCUMENTS_TAGGED_LIMIT            
				})                                                      
			rescue Mendeley::Client::ClientError => e                   
				# got no document list                                  
				#
			end                                                         
		end
	end
end
