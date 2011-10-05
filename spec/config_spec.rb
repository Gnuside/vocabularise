
require 'pp'
require 'fileutils'

require 'test/unit'
require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'vocabularise/config'

require 'spec/spec_helper'

describe 'Config' do

	before(:all) do
		json = {
			"cache_dir" => "tmp/test/cache",
			"cache_duration" => 7200,
			"consumer_key" => "d0d46ad71eb6691a44fb608424ad71c704e160d23",
			"consumer_secret" => "4fb7cd67cd36e341be6966db0b4dd261",
			"db_adapter" => "sqlite3",
			"db_database" => "tmp/test/config.sqlite3"
		}

		@config = VocabulariSe::Config.new json
	end

	it 'should contains a cache' do
		@config.should respond_to(:cache)
	end

	it 'should contain a database' do
		@config.should respond_to(:database)
	end

	it 'and database must be a hash' do
		@config.should respond_to(:database)
		db = @config.database
	end

end

