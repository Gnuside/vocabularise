
require 'mendeley'
require 'wikipedia'

require 'datamapper'
require 'dm-core'                                                               

require 'vocabularise/database_cache'
require 'vocabularise/hit_counter'
require 'vocabularise/wikipedia_ext'
require 'vocabularise/mendeley_ext'


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
			@counter = nil
			@database = nil

			load_json json
			validate	
		end

		def validate
			raise ConfigurationError, "Cache not defined" if @cache.nil?
			#raise ConfigurationError, "No mendeley client" if @mendeley_client.nil?
		end

		def load_json json
			#raise ConfigurationError, "no cache_dir specified" unless json.include? "cache_dir"

			raise ConfigurationError, "no db_adapter specified" unless json.include? "db_adapter"
			raise ConfigurationError, "no db_database specified" unless json.include? "db_database"

			case json["db_adapter"]
			when 'sqlite','sqlite3' then
				@database = {
					"adapter"   => 'sqlite3',
					"database"  => json["db_database"],
					"username"  => "",
					"password"  => "",
					"host"      => "",
					"timeout"   => 15000
				}
			when 'mysql' then
				raise ConfigurationError, "no db_password specified" unless json.include "db_password"
				raise ConfigurationError, "no db_username specified" unless json.include "db_username"
				raise ConfigurationError, "no db_host specified" unless json.include "db_host"
				@database = {	
					"adapter"   => 'mysql',
					"database"  => json["db_database"],
					"username"  => json["db_username"],
					"password"  => json["db_password"],
					"host"      => json["db_host"]
				}	
			else
				STDERR.puts json.inspect
				raise RuntimeError, "unknown database adapter"
			end

			#DataMapper::Logger.new(STDERR, :info)
			DataMapper::Logger.new(STDERR, :debug)
			DataMapper.finalize
			DataMapper.setup(:default, @database)
			DataMapper::Model.raise_on_save_failure = true                      
			DataMapper.auto_upgrade!                                            


			# setup cache & queue
			# 2 hours
			raise ConfigurationError, "no consumer_key specified" unless json.include? "consumer_key"
			raise ConfigurationError, "no cache duration specified" unless json.include? "cache_duration"

			@cache = VocabulariSe::DatabaseCache.new(60 * 60 * 2)
			
			@mendeley_client = ::Mendeley::Client.new( json["consumer_key"] )
			@mendeley_client.extend(::VocabulariSe::MendeleyExt::Cache)
			@mendeley_client.cache = cache

			@wikipedia_client = ::Wikipedia::Client.new
			@wikipedia_client.extend(::VocabulariSe::WikipediaExt::Search)
			@wikipedia_client.extend(::VocabulariSe::WikipediaExt::Cache)
			@wikipedia_client.cache = cache

			@counter = HitCounter.new
			@counter.limit :wikipedia, 500
			@counter.limit :mendeley, 500
		end
	end
end

