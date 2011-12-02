
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
require 'vocabularise/wikipedia_handler'

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

	it 'should respond to HANDLE_WIKIPEDIA_REQUEST_PAGE' do
		uuid = '47df8a70-83f6-11df-aedb-0024e8453de8'

		doc = helper_request do
			@crawler.request VocabulariSe::HANDLE_WIKIPEDIA_REQUEST_PAGE,
				{ "page" => "Love" }
		end
		#pp doc
	end

	#
end

