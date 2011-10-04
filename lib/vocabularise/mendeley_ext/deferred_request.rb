
require 'vocabularise/config'
require 'rdebug/base'
require 'mendeley/cache'
require 'cgi'

require 'vocabularise/crawler_handler'

module VocabulariSe ; module Mendeley 

	module Cache

	REQUEST_STATS_AUTHORS = :request_stats_authors

	class RequestStatsAuthorsHandler < ::VocabulariSe::CrawlerHandler::Base
		handles REQUEST_STATS_AUTHORS
		#process do |crawler|
		#	crawler
		#end
	end

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
		def initialize consumer_key, cache, crawler
			@consumer_key = consumer_key
			@base_api_url =  "http://api.mendeley.com"
			@base_site_url =  "http://www.mendeley.com"
			@cache = cache
			@debug = true
		end


		#
		#
		def stats_authors params
			crawler.request REQUEST_STATS_AUTHORS, params
			#_get_url STATS_AUTHORS_URL, params
		end


		#
		#
		def stats_papers params
			crawler.request REQUEST_STATS_PAPERS, params
			#_get_url STATS_PAPERS_URL, params
		end


		#
		#
		def stats_publications params
			crawler.request REQUEST_STATS_PUBLICATIONS, params
			#_get_url STATS_PUBLICATIONS_URL, params
		end


		#
		#
		def stats_tags params
			crawler.request REQUEST_STATS_TAGS, params
			#_get_url STATS_TAGS_URL, params
		end


		#
		#
		def documents_search params
			#validator.required_params [:items, :page]
			#validator.optional_params [:items, :page]
			crawler.request REQUEST_DOCUMENT_SEARCH, params
			#_get_url DOCUMENTS_SEARCH_URL, params
		end

		#
		#
		def documents_details params
			#validator.required_params [:id]
			#validator.optional_params [:type]
			crawler.request REQUEST_DOCUMENTS_DETAILS, params
			#_get_url DOCUMENTS_DETAILS_URL, params
		end

		#
		#
		def documents_tagged params
			#validator.required_params [:tag]
			#validator.optional_params [:items, :page]
			crawler.request REQUEST_DOCUMENTS_TAGGED, params
			#_get_url DOCUMENTS_TAGGED_URL, params
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
		def _post_url base, params
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
end
