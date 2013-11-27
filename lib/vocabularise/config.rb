
require 'mendeley'
require 'wikipedia'

require 'data_mapper'
require 'dm-core'                                                               

require 'vocabularise/model'
require 'vocabularise/cache'
require 'vocabularise/hit_counter'
require 'vocabularise/wikipedia_ext'
require 'vocabularise/mendeley_ext'

require 'delayed_job'

module VocabulariSe
	class Config

		class ConfigurationError < RuntimeError ; end

		# api clients
		attr_reader :mendeley_client
		attr_reader :wikipedia_client

		attr_reader :database

		# cache store
		attr_reader :cache
		attr_reader :counter
		attr_reader :dictionary

		def initialize json
			## default values
			@cache = nil
			@mendeley_client = nil
			@wikipedia_client = nil
			@counter = nil
			@database = nil
			@dictionary = nil

			validate_json json
			load_json json
		end

		def load_json json
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
				@database = {	
					"adapter"   => 'mysql',
					"database"  => json["db_database"],
					"username"  => json["db_username"],
					"password"  => json["db_password"],
					"host"      => json["db_host"]
				}	
			end

			DataMapper::Logger.new(STDERR, :info)
			#DataMapper::Logger.new(STDERR, :debug)
			DataMapper.finalize
			DataMapper.setup(:default, @database)
			DataMapper::Model.raise_on_save_failure = true                      
			DataMapper.auto_upgrade!                                            

			## initialize delayed job
			Delayed::Worker.max_run_time = 900
			Delayed::Worker.backend = :data_mapper

			@dictionary = json['dictionary']

			# setup cache & queue
			@cache = VocabulariSe::Cache.new( json["cache_duration_min"], json["cache_duration_max"] )

			@counter = HitCounter.new
			@counter.limit :wikipedia, 500
			@counter.limit :mendeley, 500
			
			@mendeley_client = ::Mendeley::Client.new( json["consumer_key"] )
			@mendeley_client.extend(::VocabulariSe::MendeleyExt::Cache)
			@mendeley_client.cache = cache
			@mendeley_client.hit_counter = @counter

			@wikipedia_client = ::Wikipedia::Client.new
			@wikipedia_client.extend(::VocabulariSe::WikipediaExt::Search)
			@wikipedia_client.extend(::VocabulariSe::WikipediaExt::Cache)
			@wikipedia_client.cache = cache
			@wikipedia_client.hit_counter = @counter
		end

		def validate_json json

			## database configuration
			raise ConfigurationError, "no db_adapter specified" unless json.include? "db_adapter"
			raise ConfigurationError, "no db_database specified" unless json.include? "db_database"

			case json["db_adapter"]
			when 'sqlite','sqlite3' then
				raise ConfigurationError, "db_database must be a file" unless File.exist? json['db_database']
				# nothing
			when 'mysql' then
				raise ConfigurationError, "no db_password specified" unless json.include? "db_password"
				raise ConfigurationError, "no db_username specified" unless json.include? "db_username"
				raise ConfigurationError, "no db_host specified" unless json.include? "db_host"
			else
				STDERR.puts json.inspect
				raise RuntimeError, "unknown database adapter"
			end

			## seed
			raise ConfigurationError, "no dictionary specified" unless json.include? "dictionary"

			## mendeley API
			raise ConfigurationError, "no consumer_key specified" unless json.include? "consumer_key"
			raise ConfigurationError, "no consumer_secret specified" unless json.include? "consumer_secret"

			## cache configuration
			# raise ConfigurationError, "no cache_dir specified" unless json.include? "cache_dir"
			raise ConfigurationError, "no cache_duration_min specified" unless json.include? "cache_duration_min"
			raise ConfigurationError, "no cache_duration_max specified" unless json.include? "cache_duration_max"
		end
	end
end

