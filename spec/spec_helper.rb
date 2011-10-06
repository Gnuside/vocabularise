
# all includes
require 'datamapper'
require 'dm-core'                                                               

RSpec.configure do |config|

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

