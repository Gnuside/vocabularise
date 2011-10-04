
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'datamapper'
require 'dm-core'
require 'dm-sqlite-adapter'                                                     

require 'vocabularise/config'

require 'spec/spec_helper'

describe 'Vocabularise::MendeleyExt::Cache' do

	CONSUMER_KEY = "d0d46ad71eb6691a44fb608424ad71c704e160d23"

	before :each do
		@cache = {}

		@mendeley_client = ::Mendeley::Client.new( CONSUMER_KEY )
		@mendeley_client.extend(::VocabulariSe::MendeleyExt::Cache)
		@mendeley_client.cache = @cache
	end
	
	it 'should be empty first' do
		@cache.empty?.should == true
	end

	it 'should store on request' do
		Mendeley::Document.search_tagged @mendeley_client, "love" do |doc|
			break
		end
		@cache.empty?.should == false
	end

	it 'should retrieve without any request' do
		# FIXME
		Mendeley::Document.search_tagged @mendeley_client, "love" do |doc|
			break
		end

		Mendeley::Document.search_tagged @mendeley_client, "love" do |doc|
			break
		end
		@cache.empty?.should == false
	end

end
