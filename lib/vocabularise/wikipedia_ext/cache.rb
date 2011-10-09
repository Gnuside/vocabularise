
require 'open-uri'
require 'rdebug/base'

module VocabulariSe ; module WikipediaExt

	#
	# A simple mixin adding Cache support to Wikipedia class from
	# wikipedia-client gem
	#
	module Cache

		attr_accessor :cache
		attr_accessor :hit_counter


		def initialize
			super

			@hit_counter = nil
			@cache = {}
			@debug = true
		end

		def request options
			url = url_for options
			cache_key = _cache_key options

			cache_used = false
			resp = nil

			if @cache.include? cache_key then
				rdebug "CACHE REQUEST %s" % [ url ]
				resp = @cache[cache_key]
				cache_used = true
			else
				# count a hit
				rdebug "HIT TIMING %s%s" % [ base_api_url, url ]
				@hit_counter.hit :wikipedia

				rdebug "REAL  REQUEST %s" % [ url ]
				resp = super options
			end

			@cache[cache_key] = resp unless cache_used
			return resp
		end

		private

		def _cache_key options
			id_str = options.to_a.
				sort{ |a,b| a[0].to_s <=> b[0].to_s }.
				map { |x| x.join '=' }.
				join ','

			cache_key = "wikipedia:%s" % id_str
		end
	end

end ; end
