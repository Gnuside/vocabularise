
require 'open-uri'

module VocabulariSe ; module Wikipedia

	#
	# A simple mixin adding Cache support to Wikipedia class from
	# wikipedia-client gem
	#
	module Cache

		attr_accessor :cache

		def request options
			url = url_for( options )
			cache_key = "wikipedia:request:%s" % url

			cache_used = false
			resp = nil

			if @cache.include? cache_key then
				rdebug "CACHE REQUEST %s" % [ url ]
				resp = @cache[cache_key]
				cache_used = true
			else
				rdebug "REAL  REQUEST %s" % [ url ]
				resp = super options
			end

			@cache[cache_key] = resp unless cache_used
			return resp
		end

	end

end ; end
