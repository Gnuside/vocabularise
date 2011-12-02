
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
require 'vocabularise/queue'
require 'vocabularise/request_handler'
require 'vocabularise/mendeley_handler'

require 'spec/spec_helper'


describe 'RequestHandler' do

	SLEEP_TIME = 5

	def helper_request &blk
		result = nil
		while result.nil? do 
			begin
				result = yield 
			rescue VocabulariSe::Crawler::DeferredRequest => e
				# retry ;-)
				sleep SLEEP_TIME
			end
		end
		return result
	end

	before(:all) do
		FileUtils.mkdir_p "tmp/test"

		@config = VocabulariSe::Config.new @config_json
		@crawler = VocabulariSe::Crawler.new @config

		# set crawler
		@crawler.run
	end

	before :each do
		VocabulariSe::QueueEntry.all.destroy
	end

	it 'should respond to HANDLE_MENDELEY_DOCUMENT_DETAILS' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		uuid = '47df8a70-83f6-11df-aedb-0024e8453de8'

		doc = helper_request do
			@crawler.request VocabulariSe::HANDLE_MENDELEY_DOCUMENT_DETAILS,
				{ "uuid" => uuid }
		end
		pp doc
	end

	it 'should respond to HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		intag = "love"

		page = helper_request do
			@crawler.request VocabulariSe::HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE,
				{ "tag" => intag, "page" => 0 }
		end
		pp page
	end

	it 'should respond to HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		intag = "love"

		docs = helper_request do
			@crawler.request VocabulariSe::HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED,
				{ "tag" => intag }
		end

		if docs.size > 0 then
			docs.first.kind_of?(Mendeley::Document).should == true
		end
	end

	#
end

