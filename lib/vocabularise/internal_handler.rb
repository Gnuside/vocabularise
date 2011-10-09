
require 'wikipedia'

require 'vocabularise/wikipedia_handler'
require 'vocabularise/mendeley_handler'
require 'vocabularise/request_handler'

module VocabulariSe

	HANDLE_INTERNAL_RELATED_TAGS = "internal:related_tags"
	HANDLE_INTERNAL_RELATED_TAGS_MENDELEY = "internal:related_tags:mendeley"
	HANDLE_INTERNAL_RELATED_TAGS_WIKIPEDIA = "internal:related_tags:wikipedia"

	class InternalRelatedTags < RequestHandler

		handles HANDLE_INTERNAL_RELATED_TAGS
		no_cache_result

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			rdebug "config = %s, crawler = %s" % [ @config, @crawler ]

			tags = Hash.new 0                                                   

			rdebug "try mendeley"
			# try mendeley                                                      
			if tags.empty?                                                      
				mendeley_related = @crawler.request \
					HANDLE_INTERNAL_RELATED_TAGS_MENDELEY,
					query

				tags.merge!( mendeley_related ) do |key,oldval,newval|          
					oldval + newval                                             
				end                                                             
			end                                                                 
			rdebug tags.inspect            

			rdebug "try wikipedia"
			# try wikipedia                                                     
			if tags.empty?                                                      
				wikipedia_related = @crawler.request \
					HANDLE_INTERNAL_RELATED_TAGS_WIKIPEDIA, 
					query

				tags.merge!( wikipedia_related ) do |key,oldval,newval|         
					oldval + newval                                             
				end                                                             
			end                                                                 
			# or fail                                                           

			# FIXME: cleanup common tags                                        
			tags.delete(intag)                                                  
			rdebug "result tags = %s" % tags.inspect                            
			return tags 
		end
	end


	class InternalRelatedTagsMendeley < RequestHandler

		handles HANDLE_INTERNAL_RELATED_TAGS_MENDELEY
		no_cache_result

		process do |handle, query, priority|
			intag = query[:query]

			tags = Hash.new 0                                                   

			# may fail
			documents = @crawler.request \
				HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED,
				{ :tag => intag }

			documents.each do |doc|
				document_tags = doc.tags
				rdebug "Merge document tags"                                
				rdebug "common tags : %s" % tags.inspect                    
				rdebug "   doc tags : %s" % document_tags.inspect           
				document_tags.each do |tag|                                 
					words = tag.split(/\s+/)                                
					if words.length > 1 then                                
						words.each { |w| tags[w] += 1 }                     
					else                                                    
						tags[tag] += 1                                      
					end                                                     
				end                                                         
				rdebug "merged tags : %s" % tags.inspect                    

				hit_count += 1 unless doc.cached?                           
				rdebug "hit_count = %s" % hit_count                         
				break if hit_count > limit                                  
			end                                                      

			# FIXME: cleanup mendeley-specific tags                             
			# remove tags with non alpha characters                             
			tags.keys.each do |tag|                                             
				tags.delete(tag) if tag.strip =~ /:/ ;                          
			end                                                                 
			return tags 
		end
	end

	class InternalRelatedTagsWikipedia < RequestHandler

		handles HANDLE_INTERNAL_RELATED_TAGS_WIKIPEDIA
		no_cache_result

		process do |handle, query, priority|
			intag = query[:query]

			rdebug "intag = %s" % intag                                         
			tags = Hash.new 0                                                   

			page_json = @crawler.request \
				HANDLE_WIKIPEDIA_REQUEST_PAGE, 
				query, 
				intag              

			page = Wikipedia::Page.new page_json                                
			page.links.each { |tag| tags[tag] += 1 }                            

			# FIXME: cleanup wikipedia-specific tags                            
			return tags  
		end
	end

end
