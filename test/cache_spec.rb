
$:.unshift '../lib'

require 'fileutils'
require 'test/unit'

require 'rubygems'
require 'bundler/setup'
require 'json'
require 'pp'

require 'vocabularise/config'

describe 'Cache' do
	CACHE_TIMEOUT = 60
	DB_PATH = "tmp/test/vocabularise.sqlite3"

	before :all do
		FileUtils.rm_f DB_PATH
		hash = {                                                   
			"adapter"   => 'sqlite3',                                   
			"database"  => DB_PATH,
			"username"  => "",                                          
			"password"  => "",                                          
			"host"      => "",                                          
			"timeout"   => 15000                                        
		} 
		FileUtils.mkdir_p File.dirname DB_PATH

		DataMapper::Logger.new(STDERR, :info)                               
		DataMapper.finalize                                                 
		DataMapper.setup(:default, hash)                               
		DataMapper::Model.raise_on_save_failure = true                                  
		DataMapper.auto_upgrade!

		@cache = VocabulariSe::DatabaseCache.new( CACHE_TIMEOUT )               
		puts "SETUP CALLED"
	end
	
	it 'should store' do
		@cache['A'] = '1'
		@cache['B'] = '2'
		@cache['C'] = '3'
	end

	it 'should answer to include correctly' do
		@cache.include?('A').should == true
		@cache.include?('B').should == true
		@cache.include?('C').should == true
		@cache.include?('D').should == false
	end

	it 'should retrieve' do
		@cache['A'].should == '1'
		@cache['B'].should == '2'
		@cache['C'].should == '3'
	end

	it 'should last while duration' do
	end

	it 'should not last past duration' do
	end

end

