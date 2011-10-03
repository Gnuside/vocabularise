
require 'open-uri'

module VocabulariSe
	#
	# A simple mixin adding various missing utils to Wikipedia class from
	# wikipedia-client gem
	#
	module WikipediaFix


		attr_accessor :cache

		@debug = true

		def request options
			url = url_for( options )
			cache_key = "wikipedia:%s" % url

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

		# http://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=decibel%20AND%20sound
		def search( expr, options = {} )
			request( {                                                                
				:action => "query",                                            
				:list => "search",
				:srsearch => expr
			}.merge( options ) )
		end
	end
end
