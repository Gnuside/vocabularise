
require 'vocabularise/config'
require 'rdebug/base'
require 'mendeley/cache'
require 'cgi'

require 'vocabularise/crawler_handler'

module Vocabularise ; module Mendeley 

	module Cache

		attr_accessor :cache

		#
		#
		def initialize consumer_key
			super

			@cache = {}
		end


		#
		#
		def request_get base, params
			#rdebug params.inspect
			base_api_url = URI.parse( @base_api_url )
			url = _make_url base, params
			cache_used = false
			cache_key = "mendeley:%s" % url
			resp = nil
			#pp url

			if @cache.include? url then
				rdebug "CACHE REQUEST %s%s" % [ base_api_url, url ]
				resp = @cache[cache_key]
				cache_used = true
			else
				http = Net::HTTP.start(base_api_url.host, base_api_url.port) do |http|
					rdebug "REAL  REQUEST %s%s" % [ base_api_url, url ]
					resp = http.get(url,nil)

					if ( resp["x-ratelimit-remaining"][0].to_i < RATELIMIT_EXCEEDED_LIMIT ) then
						raise RateLimitExceeded, resp.header.inspect
					end
				end
			end

			#pp resp.to_hash
			#pp resp.inspect
			json = JSON.parse resp.body
			json[JSON_CACHE_KEY] = cache_used

			if ( json[JSON_ERROR_KEY] =~ /limit\s*exceeded/ ) then
				raise RateLimitExceeded, resp.header.inspect
			elsif ( json[JSON_ERROR_KEY] =~ /temporarily\s*unavailable/ ) then
				raise ServiceUnavailable, resp.header.inspect
			end
			@cache[cache_key] = resp unless cache_used

			rdebug "result = %s" % json.inspect
			return json
		end


		#
		#
		def request_post base, params
			#rdebug params.inspect
			base_api_url = URI.parse( @base_api_url )
			url = _make_url base, params
			cache_used = false
			cache_key = "mendeley:%s" % url
			resp = nil

			if @cache.include? cache_key then
				rdebug "CACHE REQUEST %s%s" % [ base_api_url, url ]
				resp = @cache[cache_key]
				cache_used = true
			else
				http = Net::HTTP.start(base_api_url.host, base_api_url.port) do |http|
					rdebug "REAL  REQUEST %s%s" % [ base_api_url, url ]
					resp = http.get(url,nil)
					raise RateLimitExceeded

					if ( resp["x-ratelimit-remaining"][0].to_i < RATELIMIT_EXCEEDED_LIMIT ) then
						raise RateLimitExceeded, resp.header.inspect
					end
				end
			end

			#pp resp.to_hash
			#pp resp.inspect
			json = JSON.parse resp.body
			json[JSON_CACHE_KEY] = cache_used

			if ( json[JSON_ERROR_KEY] =~ /limit\s*exceeded/ ) then
				raise RateLimitExceeded, resp.header.inspect
			elsif ( json[JSON_ERROR_KEY] =~ /temporarily\s*unavailable/ ) then
				raise ServiceUnavailable, resp.header.inspect
			end
			@cache[cache_key] = resp unless cache_used

			rdebug "result = %s" % json.inspect
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
					url = url.gsub(/:#{key.to_s}/,CGI::escape(val.to_s))
				else
					url += if url_has_params then "&"
						   else
							   url_has_params = true
							   "?"
						   end
					url = url + key.to_s + "=" + CGI::escape(val.to_s)
					# add in url
				end
			end
			return url
		end

	end
end ; end 

