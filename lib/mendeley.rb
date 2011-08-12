require "net/http"
require "json"

class Mendeley

	attr_reader :base_url

	STATS_AUTHORS_URL = "/oapi/stats/authors/"
	STATS_PAPERS_URL = "/oapi/stats/papers/"
	STATS_PUBLICATIONS_URL = "/oapi/stats/publications/"
	STATS_TAGS_URL = "/oapi/stats/tags/:discipline/"
	
	DOCUMENTS_SEARCH_URL = "/oapi/documents/search/:terms/"
	DOCUMENTS_TAGGED_URL = "/oapi/documents/tagged/:tag/"

	def initialize consumer_key, cache = {}
		@consumer_key = consumer_key
		@base_url =  "http://api.mendeley.com"
		@cache = cache
	end

	def stats_authors params
		_get_url STATS_AUTHORS_URL, params
	end

	def stats_papers params
		_get_url STATS_PAPERS_URL, params
	end

	def stats_publications params
		_get_url STATS_PUBLICATIONS_URL, params
	end

	def stats_tags params
		_get_url STATS_TAGS_URL, params
	end

	def documents_search params
		#validator.required_params [:items, :page]
		#validator.optional_params [:items, :page]
		_get_url DOCUMENTS_SEARCH_URL, params
	end

	def documents_tagged params
		#validator.required_params [:tag]
		#validator.optional_params [:items, :page]
		_get_url DOCUMENTS_TAGGED_URL, params
	end

	def extra_tags_related tag
		# tag 
	end

	private


	def _get_url base, params
		pp params
		base_url = URI.parse( @base_url )
		url = _make_url base, params
		if not @cache.include? url then
			resp = Net::HTTP.start(base_url.host, base_url.port) do |http|
				puts "calling %s" % url
				resp = http.get(url,nil)
				@cache[url] = resp
			end
		else
			resp = @cache[url]
		end
		pp resp.inspect
		return JSON.parse resp.body
	end

	def _post_url base, params
		pp params
		base_url = URI.parse( @base_url )
		url = _make_url base, params
		if not @cache.include? url then
			resp = Net::HTTP.start(base_url.host, base_url.port) do |http|
				puts "calling %s" % url
				resp = http.get(url,nil)
				@cache[url] = resp
			end
		else
			resp = @cache[url]
		end
		pp resp.inspect
		return JSON.parse resp.body
	end

	def _make_url base, params
		l_params = params.dup 
		l_params[:consumer_key] = @consumer_key
		url = base.dup
		url_has_params = false
		l_params.each do |key,val|
			if url =~ /:#{key.to_s}/ then
				# match & replace
				url = url.gsub(/:#{key.to_s}/,val.to_s)
			else
				url += if url_has_params then "&"
					   else
						   url_has_params = true
						   "?"
					   end
				url = url + key.to_s + "=" + val.to_s
				# add in url
			end
		end
		return url
	end



end
