
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
		json = {
			'cache_dir' => 'tmp/test/cache',
			'cache_duration_min' => 3600,
			'cache_duration_max' => 7200,
			'consumer_key' => 'd0d46ad71eb6691a44fb608424ad71c704e160d23',
			'consumer_secret' => '4fb7cd67cd36e341be6966db0b4dd261',

			"db_adapter" => "mysql",
			"db_database" => "vocabularise_test",
			"db_host" => "localhost",
			"db_username" => "vocabularise",
			"db_password" => "vocapass"
=begin
			"db_adapter"   => 'sqlite3',
			"db_database"  => 'tmp/test/cache.sqlite3',
			"db_username"  => "",
			"db_password"  => "",
			"db_host"      => "",
=end
		}

		@config = VocabulariSe::Config.new json
		@crawler = VocabulariSe::Crawler.new @config

		#DataMapper::Logger.new(STDERR, :debug)
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

