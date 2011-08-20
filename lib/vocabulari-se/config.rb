module VocabulariSe
	class Config

		# api clients
		attr_reader :mendeley_client
		attr_reader :wikipedia_client

		# cache store
		attr_reader :cache


		def initialize json
			@cache = VocabulariSe::DirectoryCache.new json["cache_dir"], (60 * 60 * 24)
			@mendeley_client = Mendeley::Client.new( json["consumer_key"], cache )
			@wikipedia_client = Wikipedia::Client.new
		end
	end
end

