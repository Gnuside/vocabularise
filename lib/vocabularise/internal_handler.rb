
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
		cache_result DURATION_SHORT

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			intag = query['tag']

			tags = Hash.new 0                                                   

			rdebug "try mendeley"
			# try mendeley                                                      
			if tags.empty?                                                      
				mendeley_related = @crawler.request \
					HANDLE_INTERNAL_RELATED_TAGS_MENDELEY,
					{ :tag => intag }

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
					{ :tag => intag }

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
		cache_result DURATION_SHORT

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			intag = query['tag']

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
		cache_result DURATION_SHORT

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			intag = query['tag']

			rdebug "intag = %s" % intag                                         
			tags = Hash.new 0                                                   

			page_json = @crawler.request \
				HANDLE_WIKIPEDIA_REQUEST_PAGE, 
				{ :page => intag }, 
				intag              

			page = Wikipedia::Page.new page_json                                
			page.links.each { |tag| tags[tag] += 1 }                            

			final_tags = []
			tags.keys.each do |tag|                                             
				ftag = tag.dup # prevent modification on a frozen string
				ftag.gsub!(/ \(.*\)$/,'')
				final_tags << tag
			end                                                                 
			# FIXME: cleanup wikipedia-specific tags                            
			return final_tags
		end
	end

end
