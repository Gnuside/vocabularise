
module VocabulariSe
	#
	# A simple mixin adding various missing utils to Wikipedia class from
	# wikipedia-client gem
	#
	module WikipediaFix


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
