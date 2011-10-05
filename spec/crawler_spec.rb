
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'vocabularise/config'
require 'vocabularise/crawler'
require 'vocabularise/model'

require 'spec/spec_helper'

describe 'Crawler' do

	before(:all) do
		json = {
			'cache_dir' => 'tmp/test/cache',
			'cache_duration' => 7200,
			'consumer_key' => 'd0d46ad71eb6691a44fb608424ad71c704e160d23',
			'consumer_secret' => '4fb7cd67cd36e341be6966db0b4dd261',
			'db_adapter' => 'sqlite3',
			'db_database' => 'tmp/test/crawler.sqlite3'
		}

		@config = VocabulariSe::Config.new json
		@crawler = VocabulariSe::Crawler.new

		# set crawler
		@config.mendeley_client.crawler = crawler
		#crawler.run
	end

	before :each do
		CrawlerQueueEntry.all.destroy
	end

	#
	it 'should find handlers' do
		@crawler.should respond_to :find_handlers

		# FIXME:
		@crawler.find_handler handle do |handler|
		end
	end

	#

end

