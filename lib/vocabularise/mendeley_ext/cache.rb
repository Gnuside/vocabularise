
require 'vocabularise/config'
require 'rdebug/base'
require 'mendeley/cache'
require 'cgi'

require 'vocabularise/request_handler'

module VocabulariSe ; module MendeleyExt

	module Cache

		attr_accessor :cache
		attr_accessor :hit_counter

		#
		#
		def initialize consumer_key
			super

			@hit_counter = nil
			@cache = {}
			@debug = true
		end

		#
		#
		def old_request_url base, params, &blk
			
			url = create_url base, params
			cache_used = false
			cache_key = "mendeley:%s,%s" % [ base, params ]
			resp = nil

			if @cache.include? url then
				rdebug "CACHE REQUEST %s%s" % [ base_api_url, url ]
				resp = @cache[cache_key]
				cache_used = true
			else
				# count a hit
				rdebug "HIT TIMING %s%s" % [ base_api_url, url ]
				@hit_counter.hit :mendeley

				http = Net::HTTP.start(base_api_url.host, base_api_url.port) do |http|
					rdebug "REAL  REQUEST %s%s" % [ base_api_url, url ]
					resp = yield http

					if ( resp["x-ratelimit-remaining"][0].to_i < RATELIMIT_EXCEEDED_LIMIT ) then
						raise RateLimitExceeded, resp.header.inspect
					end
				end
			end

			json = JSON.parse resp.body
			json[JSON_CACHE_KEY] = cache_used

			case json[JSON_ERROR_KEY]
			when /limit\s*exceeded/ then
				raise RateLimitExceeded, resp.header.inspect
			when /temporarily\s*unavailable/ then
				raise ServiceUnavailable, resp.header.inspect
			end
			@cache[cache_key] = resp unless cache_used

			rdebug "result = %s" % json.inspect
			exit 1 #FIXME: debug
			return json
		end


		#
		#
		def request_url base, params, &blk
			url = create_url base, params
			cache_key = _cache_key base, params
			resp = nil

			if @cache.include? cache_key then
				rdebug "CACHE REQUEST %s%s" % [ base_api_url, url ]
				resp = @cache[cache_key]
			else
				rdebug "REAL  REQUEST %s%s" % [ base_api_url, url ]
				resp = super base, params, &blk
				@cache[cache_key] = resp
			end

			return resp
		end

		private

		def _cache_key base, params
			id_str = params.to_a.
				sort{ |a,b| a[0].to_s <=> b[0].to_s }.
				map { |x| x.join '=' }.
				join ','

			cache_key = "mendeley:%s,%s" % [ base, id_str ]
		end
	end
end ; end 

