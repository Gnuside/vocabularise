
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


describe 'ExpectedHandler' do

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

