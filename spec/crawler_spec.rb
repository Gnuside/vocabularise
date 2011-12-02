
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
		FileUtils.mkdir_p "tmp/test"

		@config = VocabulariSe::Config.new @config_json
		@crawler = VocabulariSe::Crawler.new @config

		# set crawler
		@crawler.run
	end

	before :each do
		VocabulariSe::QueueEntry.all.destroy
	end


	#
=begin
	it 'should find handlers' do
		@crawler.should respond_to(:find_handlers)

		pending("test returned handlers")
		# FIXME:
		@crawler.find_handlers "example" do |handler|
			pp handler
		end
	end
=end

	#

end

