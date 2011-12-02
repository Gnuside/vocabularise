
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'vocabularise/model'
require 'vocabularise/config'
require 'vocabularise/crawler'
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
		FileUtils.mkdir_p "tmp/test"

		@config = VocabulariSe::Config.new @config_json
		@crawler = VocabulariSe::Crawler.new @config

		# set crawler
		@crawler.run
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

