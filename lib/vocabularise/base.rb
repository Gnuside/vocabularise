

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

		# Static page
		get "/about" do
			@title = "About"
			haml :page_about
		end

		# Static page
		get "/faq" do
			@title = "F.A.Q"
			haml :page_faq
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


		# Return information about mendeley documents for tag tag :tag 
		# restricted to search :search
		get "/tag/:tag/mendeley_doc/:search" do
			# FIXME: use cache for search/tag
			raise NotImplementedError
		end


		# Return information about mendeley disciplines for tag tag :tag 
		# restructed to search :search
		get "/tag/:tag/mendeley_disc/:search" do
			# FIXME: use cache for search/tag
			raise NotImplementedError
		end


		# Return information about wikipedia pages for tag tag :tag 
		# restricted to search :search
		get "/tag/:tag/wikipedia_page/:search" do
			# FIXME: use cache for search/tag
			raise NotImplementedError
		end


	end

end
