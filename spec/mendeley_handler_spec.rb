
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

require 'spec/spec_helper'


describe 'RequestHandler' do

	before(:all) do
		json = {
			'cache_dir' => 'tmp/test/cache',
			'cache_duration' => 7200,
			'consumer_key' => 'd0d46ad71eb6691a44fb608424ad71c704e160d23',
			'consumer_secret' => '4fb7cd67cd36e341be6966db0b4dd261',
			"db_adapter" => "mysql",
			"db_database" => "vocabularise_test",
			"db_host" => "localhost",
			"db_username" => "vocabularise",
			"db_password" => "vocapass"
		}

		@config = VocabulariSe::Config.new json
		@crawler = VocabulariSe::Crawler.new @config

		# set crawler
		@crawler.run
	end

	before :each do
		VocabulariSe::QueueEntry.all.destroy
	end

	it 'should respond to HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE' do
		intag = "love"

		page0 = nil
		#related_tags = VocabulariSe::Utils.related_tags config, intag
		loop do 
			begin
				page0 = @crawler.request VocabulariSe::HANDLE_MENDELEY_DOCUMENT_SEARCH_TAGGED_PAGE,
					{ "tag" => intag, "page" => 0 }, VocabulariSe::Crawler::MODE_INTERACTIVE
			rescue VocabulariSe::Crawler::DeferredRequest => e
				#puts "deferred" + e.message
				#puts e.backtrace
				sleep 1
			end
		end
		pp page0
	end

	#
end

