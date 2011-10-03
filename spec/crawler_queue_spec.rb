
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

require 'wikipedia'
require 'vocabularise/crawler_queue'

describe 'CrawlerQueue' do

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

		@queue = ::VocabulariSe::CrawlerQueue.new
	end

	def helper_make_samepriority
		@queue.empty!
		@queue.push :related, 'love'
		@queue.push :expected, 'death'
		@queue.push :aggregating, 'love'
	end

	def helper_make_diffpriority
		@queue.empty!
		@queue.push :related, 'love', 2
		@queue.push :expected, 'death', 0
		@queue.push :aggregating, 'love', 1
	end

	#
	it 'should be empty at start' do
		@queue.should respond_to :empty?

		@queue.empty?.should == true
		@queue.size.should == 0
	end

	#
	it 'should push (handle,query)' do
		@queue.should respond_to :push

		@queue.push :related, 'love'
		@queue.size.should == 1
		@queue.push :expected, 'love'
		@queue.size.should == 2
		@queue.empty?.should == false
	end


	#
	it 'should by empty-able' do
		@queue.should respond_to :empty!

		@queue.size.should >= 0
		@queue.empty!
		@queue.size.should == 0
		@queue.empty?.should == true
	end


	#
	it 'should allow test on included (handle,query)' do
		@queue.should respond_to :include?

		@queue.empty!
		@queue.include?(:related, 'love').should == false
		@queue.push :related, 'love'
		@queue.include?(:related, 'love').should == true
		@queue.include?(:expected, 'love').should == false
	end


	#
	it 'should allow access to first' do
		@queue.should respond_to :first

		helper_make_samepriority

		handler, query, priority = @queue.first
		handler.to_sym.should == :related
		query.should == 'love'
	end


	#
	it 'should be shift-able' do
		@queue.should respond_to :shift

		helper_make_samepriority

		@queue.shift.shift

		handler, query, priority = @queue.first
		handler.to_sym.should == :aggregating
		query.should == 'love'
	end


	#
	it 'should be pop-able' do
		@queue.should respond_to :shift

		helper_make_samepriority

		@queue.shift
		handler, query, priority = @queue.pop

		handler.to_sym.should == :expected
		query.should == 'death'
	end


	#
	it 'should not shift empty queue' do
		@queue.empty!

		lambda{ @queue.shift }.should raise_error VocabulariSe::CrawlerQueue::EmptyQueueError
	end


	#
	it 'should iterate through entries' do
		@queue.should respond_to :each

	end


	#
	it 'should prioritize' do
	end


	#
	it 'should preserve order' do
		@queue.push :A, 1
		@queue.push :B, 2
		@queue.push :C, 3
	end

end

