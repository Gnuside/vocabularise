
require 'vocabularise/request_handler'

module VocabulariSe

	HANDLE_INTERNAL_CONTROVERSIAL = "internal:controversial"

	class InternalAggregating < RequestHandler

		handles HANDLE_INTERNAL_CONTROVERSIAL
		cache_result DURATION_SHORT

		# limit the number of considered articles for computation               
		ARTICLE_LIMIT = 3                                                       

		def tag_hotness tags_arr                                        
			search_expr = '"%s"' % tags_arr.sort.join('" AND "')                
			puts search_expr                                                    

			raise NotImplementedError

			resp_json =  config.wikipedia_client.search( search_expr )          
			resp = JSON.parse resp_json                                         

			score = 0                                                           
			limit = ARTICLE_LIMIT                                               
			resp["query"]["search"].each do |article_desc|                      
				talk_title = "Talk:%s" % article_desc["title"]                  
				puts "  - " + talk_title                                        
				#pp article_desc                                                
				page_json = config.wikipedia_client.request_page talk_title     
				begin                                                           
					page = Wikipedia::Page.new page_json                        
					raw = page.content                                          
				rescue Timeout::Error => e                                      
					puts "  WARNING: timeout error"                             
					next                                                        
				end                                                             
				#puts raw                                                       
				titles = (raw.split(/\n/) rescue []).select{ |line| line.strip =~ /^\s*==.*==\s*/ } 
				score += titles.size                                            
				#page.links.each { |tag| tags[tag] += 1 }                       

				limit -= 1                                                      
				break if limit <= 0                                             
			end                                                                 
			puts "  * score = %s" % score                                       
			return score                                                        
		end 

		process do |handle, query, priority|
			@debug = true
			rdebug "handle = %s, query = %s, priority = %s " % \
				[ handle, query.inspect, priority ]
			raise ArgumentError, "no 'tag' found" unless query.include? 'tag'
			intag = query['tag']
			raise ArgumentError, "'tag' must not be nil" if intag.nil?

			# Association audacieuse                                            
			workspace = {}                                                      
			documents = Set.new                                                 
			related_tags = @crawler.request \
				HANDLE_INTERNAL_RELATED_TAGS, 
				{ "tag" => intag }

			related_tags.each do |reltag,reltag_count|                          
				hotness = tag_hotness( [reltag, intag] )                

				workspace[reltag] = {                                           
					:hotness => hotness                                         
				}                                                               
			end                                                                 

			# sort workspace keys (tags) by slope                               
			result = workspace.sort{ |a,b| a[1][:hotness] <=> b[1][:hotness] }.reverse

			# FIXME : use archive pages if needed                               
			return result
		end
	end
end
