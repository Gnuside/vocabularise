
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'data_mapper'
require 'dm-core'
require 'dm-sqlite-adapter'                                                     

require 'vocabularise/cache'

require 'spec/spec_helper'

describe 'Cache' do
	CACHE_TIMEOUT = 5

	before :all do
		hash = {                                                   
			"adapter"   => 'sqlite3',                                   
			"database"  => 'tmp/test/cache.sqlite3',
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
	end

	before :each do
		@cache = VocabulariSe::Cache.new( CACHE_TIMEOUT )               
		@cache.empty!
	end
	
	it 'should store' do
		@cache['A'] = '1'
		@cache['B'] = '2'
		@cache['C'] = '3'
	end

	it 'should be able to store twice' do
		@cache['A'] = '1'
		@cache['A'] = '1'
	end
	
	it 'should be able to store big data' do
		@cache['A'] = '1' * 100
		@cache['A'] = '2' * 1000
		@cache['A'] = '3' * 10000
		@cache['A'] = '4' * 100000
		@cache['A'] = '1'
	end

	it 'should answer to include correctly' do
		@cache['A'] = '1'
		@cache['B'] = '2'
		@cache['C'] = '3'
		@cache.include?('A').should == true
		@cache.include?('B').should == true
		@cache.include?('C').should == true
		@cache.include?('D').should == false
	end

	it 'should retrieve' do
		@cache['A'] = '1'
		@cache['B'] = '2'
		@cache['C'] = '3'
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

	it 'should be expungeable' do
		@cache.should respond_to(:expunge!)

		inside = [ 'A', 'B', 'C' ]
		outside = ['D']

		@cache['A'] = '1'
		@cache['B'] = '2'
		@cache['C'] = '3'

		@cache.expunge!

		@cache.each do |entry|
			inside.include?(entry.id).should == true
			outside.include?(entry.id).should == false
		end
	end
end

