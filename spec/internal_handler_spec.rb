
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
require 'vocabularise/mendeley_handler'
require 'vocabularise/internal_handler'

require 'vocabularise/expected_handler'

require 'spec/spec_helper'


describe 'InternalHandler' do

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

	it 'should respond to HANDLE_INTERNAL_RELATED_TAGS_MENDELEY' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		intag = "love"

		reltags = helper_request do
			@crawler.request VocabulariSe::HANDLE_INTERNAL_RELATED_TAGS_MENDELEY,
				{ "tag" => intag }
		end
		pp reltags
	end

	it 'should respond to HANDLE_INTERNAL_RELATED_TAGS_WIKIPEDIA' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		intag = "love"

		reltags = helper_request do
			@crawler.request VocabulariSe::HANDLE_INTERNAL_RELATED_TAGS_WIKIPEDIA,
				{ "tag" => intag }
		end
		pp reltags
	end

	it 'should respond to HANDLE_INTERNAL_RELATED_TAGS' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		intag = "love"

		reltags = helper_request do
			@crawler.request VocabulariSe::HANDLE_INTERNAL_RELATED_TAGS,
				{ "tag" => intag }
		end
		pp reltags
	end


	it 'should respond to HANDLE_INTERNAL_RELATED_DOCUMENTS' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		intag = ["love","fmri"]

		reldocs = helper_request do
			@crawler.request VocabulariSe::HANDLE_INTERNAL_RELATED_DOCUMENTS,
				{ "tag_list" => intag }
		end
		pp reldocs
	end



	it 'should respond to HANDLE_INTERNAL_EXPECTED' do
		STDOUT.puts "press [enter] to start"
		STDIN.gets
		intag = "love"

		reltags = helper_request do
			@crawler.request VocabulariSe::HANDLE_INTERNAL_EXPECTED,
				{ "tag" => intag }
		end
		pp reltags
	end
	#
end

