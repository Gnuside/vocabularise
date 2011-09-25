

module VocabulariSe

	class Base < ::Sinatra::Base

		enable :sessions                                                                                                
		enable :run 

		set :static, true                                                                                               
		set :public, File.expand_path( File.dirname(__FILE__) + '/../../static' )                                          
		set :views, File.expand_path( File.dirname(__FILE__) + '/../../views' )     

		mime_type :ttf, "application/octet-stream"                                                                      
		mime_type :eot, "application/octet-stream"                                                                      
		mime_type :otf, "application/octet-stream"                                                                      
		mime_type :woff, "application/octet-stream"   

		# Index page
		get "/" do
			raise NotImplementedError
		end


		# Return the result page for given search expression
		get "/search/:search" do
			# FIXME: use cache for search
			raise NotImplementedError
		end


		# Show request queue
		get "/status/request_queue" do
		end


		# Show current cache
		get "/status/cache" do 
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
