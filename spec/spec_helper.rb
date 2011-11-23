
# all includes
require 'data_mapper'
require 'dm-core'
require 'json'

RSpec.configure do |config|
	config.fail_fast = true


	config.before(:suite) do
		#STDERR.puts "HELPER - BEFORE SUITE"
	end


	config.before(:all) do
		hash = {                                                   
			"adapter"   => 'sqlite3',                                   
			"database"  => ':memory:',
			"username"  => "",                                          
			"password"  => "",                                          
			"host"      => "",                                          
			"timeout"   => 15000                                        
		} 

		config_path = File.expand_path 'spec/config/vocabularise.json'
		@config_json = JSON.parse File.open( config_path ).read

		#DataMapper::Logger.new(STDERR, :debug)
		DataMapper::Logger.new(STDERR, :info)
		DataMapper.finalize
		DataMapper.setup(:default, hash)                               
		DataMapper::Model.raise_on_save_failure = true                                  
		DataMapper.auto_migrate!
		#STDERR.puts "HELPER - BEFORE ALL"
	end


	config.before(:each) do
	end

	config.after(:all) do
	end

	config.after(:each) do
	end

end

