
class API < Sinatra::Base

	# Index page
	get "/" do
		raise NotImplementedError
	end


	# Return the result page for given search expression
	get "/search/:search" do
		# FIXME: use cache for search
		raise NotImplementedError
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


