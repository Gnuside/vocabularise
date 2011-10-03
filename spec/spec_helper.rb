
# all includes

RSpec.configure do |config|

	config.before(:all) do
		hash = {                                                   
			"adapter"   => 'sqlite3',                                   
			"database"  => ':memory:',
			"username"  => "",                                          
			"password"  => "",                                          
			"host"      => "",                                          
			"timeout"   => 15000                                        
		} 

		DataMapper::Logger.new(STDERR, :info)                               
		DataMapper.finalize                                                 
		DataMapper.setup(:default, hash)                               
		DataMapper::Model.raise_on_save_failure = true                                  
		DataMapper.auto_migrate!
	end

	config.before(:each) do
	end

	config.after(:all) {}
	config.after(:each) {}
end

