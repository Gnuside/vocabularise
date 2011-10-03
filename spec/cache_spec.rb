
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'datamapper'
require 'dm-core'
require 'dm-sqlite-adapter'                                                     

require 'vocabularise/config'


describe 'DatabaseCache' do
	CACHE_TIMEOUT = 5
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
		@cache['D'].should == nil
	end

	it 'should last while duration' do
		@cache['A'] = '1'
		sleep CACHE_TIMEOUT * 0.5
		@cache['A'].should == '1'
	end

	it 'should not last past duration' do
		@cache['A'] = '1'
		sleep CACHE_TIMEOUT * 1.1
		@cache['A'].should == nil
	end

	it 'should create a database file' do
		File.exist?(DB_PATH).should == true
	end

	it 'should list all entries' do
		inside = [ 'A', 'B', 'C' ]
		outside = ['D']

		@cache['A'] = '1'
		@cache['B'] = '2'
		@cache['C'] = '3'
		@cache.each do |entry|
			inside.include?(entry.id).should == true
			outside.include?(entry.id).should == false
		end
	end
end

