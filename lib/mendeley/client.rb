
require 'vocabularise/config'
require 'rdebug/base'
require 'mendeley/cache'
require 'cgi'

require 'vocabularise/crawler_handler'

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
		JSON_ERROR_KEY = "error"

		class RateLimitExceeded < RuntimeError ; end
		class ServiceUnavailable < RuntimeError ; end

		#
		#
		def initialize consumer_key
			@consumer_key = consumer_key
			@base_api_url =  "http://api.mendeley.com"
			@base_site_url =  "http://www.mendeley.com"
			@debug = true
		end


		#
		#
		def stats_authors params
			request_get STATS_AUTHORS_URL, params
		end


		#
		#
		def stats_papers params
			request_get STATS_PAPERS_URL, params
		end


		#
		#
		def stats_publications params
			request_get STATS_PUBLICATIONS_URL, params
		end


		#
		#
		def stats_tags params
			request_get STATS_TAGS_URL, params
		end


		#
		#
		def documents_search params
			#validator.required_params [:items, :page]
			#validator.optional_params [:items, :page]
			request_get DOCUMENTS_SEARCH_URL, params
		end

		#
		#
		def documents_details params
			#validator.required_params [:id]
			#validator.optional_params [:type]
			request_get DOCUMENTS_DETAILS_URL, params
		end

		#
		#
		def documents_tagged params
			#validator.required_params [:tag]
			#validator.optional_params [:items, :page]
			request_get DOCUMENTS_TAGGED_URL, params
		end


		#
		#
		def extra_tags_related tag
			# tag 
		end


		#
		#
		def request_url base, params, &blk
			base_api_url = URI.parse( @base_api_url )
			url = create_url base, params
			rdebug "REQUEST %s%s" % [ base_api_url, url ]
			resp = nil

			http = Net::HTTP.start(base_api_url.host, base_api_url.port) do |http|
				resp = http.get(url,nil)

				if ( resp["x-ratelimit-remaining"][0].to_i < RATELIMIT_EXCEEDED_LIMIT ) then
					raise RateLimitExceeded, resp.header.inspect
				end
			end

			json = JSON.parse resp.body

			if ( json[JSON_ERROR_KEY] =~ /limit\s*exceeded/ ) then
				raise RateLimitExceeded, resp.header.inspect
			elsif ( json[JSON_ERROR_KEY] =~ /temporarily\s*unavailable/ ) then
				raise ServiceUnavailable, resp.header.inspect
			end

			return json
		end

		
		#
		#
		def request_get base, params
			request_url(base, params){ |http| http.get(url,nil) }
		end

		#
		#
		def request_post base, params
			request_url(base, params){ |http| http.post(url,nil) }
		end


		#
		# Returns a valid url for given parameters
		#
		def create_url base, params
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
end
