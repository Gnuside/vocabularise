
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'vocabularise/model'
require 'vocabularise/request_handler'

require 'spec/spec_helper'


describe 'RequestHandler' do

	class TestHandler < VocabulariSe::RequestHandler
		handles :good_example, :good_other_example
		no_cache_result

		process do |handle,query,priority|
			#@crawler.request :good_example, query, priority + 1

			puts "hello world"
		end
	end

	before(:all) do
		json = {
			'cache_dir' => 'tmp/test/cache',
			'cache_duration_min' => 3600,
			'cache_duration_max' => 7200,
			'consumer_key' => 'd0d46ad71eb6691a44fb608424ad71c704e160d23',
			'consumer_secret' => '4fb7cd67cd36e341be6966db0b4dd261',
			'db_adapter' => 'sqlite3',
			'db_database' => 'tmp/test/crawler.sqlite3'
		}

		# set crawler
	end

	before :each do
	end

	#
	it 'should list handlers' do
		#th = TestHandler.new nil, nil
		handlers = VocabulariSe::RequestHandler.subclasses
		handlers.include?(TestHandler).should == true
	end

	it 'should correctly match the handle' do
		TestHandler.should respond_to :handles?
		TestHandler.handles?(:good_example).should == true
		TestHandler.handles?(:good_other_example).should == true
		TestHandler.handles?(:bad_example).should == false
	end

	it 'should process the handle, query, priority, etc.' do
		pending("implement it")
	end

	#
end

