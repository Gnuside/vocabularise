
require 'vocabularise/cache'
require 'vocabularise/wikipedia'
require 'mendeley'
require 'wikipedia'

module VocabulariSe
	class Config

		class ConfigurationError < RuntimeError ; end

		# api clients
		attr_reader :mendeley_client
		attr_reader :wikipedia_client

		attr_reader :database

		# cache store
		attr_reader :cache

		def initialize json
			# default values
			@cache = nil
			@mendeley_client = nil
			@wikipedia_client = nil

			load_json json
			validate	
		end

		def validate
			raise ConfigurationError, "Cache not defined" if @cache.nil? 
			raise ConfigurationError, "No consumer key defined" if @mendeley_client.nil?
		end

		def load_json json
			raise ConfigurationError, "no cache_dir specified" unless json.include? "cache_dir"
			# 2 hours
			@cache = VocabulariSe::DirectoryCache.new json["cache_dir"], (60 * 60 * 2)
			# 1 day
			#@cache = VocabulariSe::DirectoryCache.new json["cache_dir"], (60 * 60 * 24)

			raise ConfigurationError, "no consumer_key specified" unless json.include? "consumer_key"
			@mendeley_client = Mendeley::Client.new( json["consumer_key"], cache )
			@wikipedia_client = Wikipedia::Client.new
			@wikipedia_client.extend(WikipediaFix)

			raise ConfigurationError, "no db_adapter specified" unless json.include? "db_adapter"
			raise ConfigurationError, "no db_database specified" unless json.include? "db_database"

			case json["db_adapter"]
			when 'sqlite' then                                                                                          
				@database = {                                                                                                
					"adapter"   => 'sqlite3',                                                                           
					"database"  => json["db_database"],
					"username"  => "",                                                                                  
					"password"  => "",                                                                                  
					"host"      => "",                                                                                  
					"timeout"   => 15000                                                                                
				}                                                                                                       
			when 'mysql' then                                                                                           
				raise ConfigurationError, "no db_password specified" unless json.include? "db_password"
				raise ConfigurationError, "no db_username specified" unless json.include? "db_username"
				raise ConfigurationError, "no db_host specified" unless json.include? "db_host"
				@database = {	
					"adapter"   => 'mysql',                                                                             
					"database"  => json["db_database"],
					"username"  => json["db_username"],                                                                           
					"password"  => json["db_password"],
					"host"      => json["db_host"]
				}	
			else
				#raise UnknownAdapter, @adapter
			end

		end
	end
end

