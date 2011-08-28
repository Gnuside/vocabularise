
module VocabulariSe
	#
	# A simple mixin adding cache support to Wikipedia class from
	# wikipedia-client gem
	#
	module WikipediaCache

		def cached?
			return true
		end
	end
end
