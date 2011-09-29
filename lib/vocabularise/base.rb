

module VocabulariSe

	class Base < ::Sinatra::Base

		enable :sessions                                                                                                
		enable :run 

		set :haml, :format => :html5 # default Haml format is :xhtml

		set :static, true                                                                                               
		set :public, File.expand_path( File.dirname(__FILE__) + '/../../static' )                                          
		set :views, File.expand_path( File.dirname(__FILE__) + '/../../templates' )     

		mime_type :ttf, "application/octet-stream"                                                                      
		mime_type :eot, "application/octet-stream"                                                                      
		mime_type :otf, "application/octet-stream"                                                                      
		mime_type :woff, "application/octet-stream"   

		helpers Sinatra::ContentFor

		# Static page
		get "/about" do
			@title = "About"
			haml :page_about
		end

		# Static page
		get "/news" do
			@title = "News"
			haml :page_news
		end

		# Static page
		get "/contact" do
			@title = "Contact"
			haml :page_contact
		end

		#
		#
		# Index page
		get "/" do
			@title = "Index"
			haml :page_index
		end


		# Return the result page for given search expression
		get "/search" do
			# FIXME: use cache for search
			@query = params[:query]
			haml :page_search
		end

		# Show request queue
		get "/status/request_queue" do
			haml :page_request_queue
		end


		# Show current cache
		get "/status/cache" do 
			haml :page_cache
		end


		# Return results for expected algorithm
		get "/search/expected" do
			# FIXME: use cache for search/tag
			@query = params[:query]

			# ask related tags in cache
			# return a 503 (server not ready) error if missing
			JSON.generate( {
				:algorithm => "expected",
				:result => [
					[:tag1,:tag1_blabla],
					[:tag2,:tag2_blabla]] 
			} )
		end


		# Return results for aggregating algorithm
		get "/search/controversial" do
			# FIXME: use cache for search/tag
			@query = params[:query]
			#
			# ask related tags in cache
			# return a 503 (server not ready) error if missing
			sleep 2
			JSON.generate( { 
				:algorithm => "controversial",
				:result => [
					[:tag1,:tag1_blabla],
					[:tag2,:tag2_blabla]] 
			} )
		end


		# Return information about wikipedia pages for tag tag :tag 
		get "/search/aggregating" do
			# FIXME: use cache for search/tag
			@query = params[:query]
			#
			# ask related tags in cache
			# return a 503 (server not ready) error if missing
			sleep 5
			JSON.generate( { 
				:algorithm => "aggregating",
				:result => [
					[:tag1,:tag1_blabla],
					[:tag2,:tag2_blabla]] 
			} )
		end


	end

end
