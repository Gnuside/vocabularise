
module Mendeley
	class Client

		attr_reader :base_api_url,
			:base_site_url

		STATS_AUTHORS_URL = "/oapi/stats/authors/"
		STATS_PAPERS_URL = "/oapi/stats/papers/"
		STATS_PUBLICATIONS_URL = "/oapi/stats/publications/"
		STATS_TAGS_URL = "/oapi/stats/tags/:discipline/"

		DOCUMENTS_SEARCH_URL = "/oapi/documents/search/:terms/"
		DOCUMENTS_DETAILS_URL = "/oapi/documents/details/:id/"
		DOCUMENTS_TAGGED_URL = "/oapi/documents/tagged/:tag/"

		RATELIMIT_EXCEEDED_LIMIT = 5

		class RateLimitExceeded < RuntimeError ; end

		#
		#
		def initialize consumer_key, cache = {}
			@consumer_key = consumer_key
			@base_api_url =  "http://api.mendeley.com"
			@base_site_url =  "http://www.mendeley.com"
			@cache = cache
		end


		#
		#
		def stats_authors params
			_get_url STATS_AUTHORS_URL, params
		end


		#
		#
		def stats_papers params
			_get_url STATS_PAPERS_URL, params
		end


		#
		#
		def stats_publications params
			_get_url STATS_PUBLICATIONS_URL, params
		end


		#
		#
		def stats_tags params
			_get_url STATS_TAGS_URL, params
		end


		#
		#
		def documents_search params
			#validator.required_params [:items, :page]
			#validator.optional_params [:items, :page]
			_get_url DOCUMENTS_SEARCH_URL, params
		end

		#
		#
		def documents_details params
			#validator.required_params [:id]
			#validator.optional_params [:type]
			_get_url DOCUMENTS_DETAILS_URL, params
		end

		#
		#
		def documents_tagged params
			#validator.required_params [:tag]
			#validator.optional_params [:items, :page]
			_get_url DOCUMENTS_TAGGED_URL, params
		end


		#
		#
		def extra_tags_related tag
			# tag 
		end

		private


		#
		#
		def _get_url base, params
			pp params
			base_api_url = URI.parse( @base_api_url )
			url = _make_url base, params
			cache_used = false
			#pp url

			if @cache.include? url then
				resp = @cache[url]
				cache_used = true
			else
				resp = Net::HTTP.start(base_api_url.host, base_api_url.port) do |http|
					puts "MAKING REQUEST calling %s" % url
					resp = http.get(url,nil)

					if resp["x-ratelimit-remaining"][0].to_i < RATELIMIT_EXCEEDED_LIMIT then
						raise RateLimitExceeded
					end
					@cache[url] = resp
				end
			end

			#pp resp.to_hash
			#pp resp.inspect
			json = JSON.parse resp.body
			json['x-cache-used'] = cache_used
			return json
		end


		#
		#
		def _post_url base, params
			pp params
			base_api_url = URI.parse( @base_api_url )
			url = _make_url base, params
			cache_used = false

			if @cache.include? url then
				resp = @cache[url]
				cache_used = true
			else
				resp = Net::HTTP.start(base_api_url.host, base_api_url.port) do |http|
					puts "MAKING REQUEST calling %s" % url
					resp = http.get(url,nil)
					raise RateLimitExceeded

					if resp["x-ratelimit-remaining"][0].to_i < RATELIMIT_EXCEEDED_LIMIT then
						raise RateLimitExceeded
					end
					@cache[url] = resp
				end
			end

			#pp resp.to_hash
			#pp resp.inspect
			json = JSON.parse resp.body
			json['x-cache-used'] = cache_used
			return json
		end


		#
		#
		def _make_url base, params
			l_params = params.dup 
			l_params[:consumer_key] = @consumer_key
			url = base.dup
			url_has_params = false
			l_params.each do |key,val|
				# skip parameter called limit
				next if key == :limit
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
end
