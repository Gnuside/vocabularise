
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'wikipedia'
require 'vocabularise/wikipedia_ext'

require 'vocabularise/hit_counter'

describe 'Wikipedia' do

	before :each do
		@wikipedia_client = Wikipedia::Client.new                           

		@counter = VocabulariSe::HitCounter.new
		@counter.limit :wikipedia, 500
	end
	
	it 'should search' do
		@wikipedia_client.extend(::VocabulariSe::WikipediaExt::Search)                              

		@wikipedia_client.should respond_to(:search)
		result = @wikipedia_client.search "Love"
		result.kind_of?(String).should == true

		json = JSON.parse result
		json.include?("query").should == true
	end

	it 'should request pages' do
		@wikipedia_client.should respond_to(:request_page)
		result = @wikipedia_client.request_page "Love"
		result.kind_of?(String).should == true

		json = JSON.parse result
		json.include?("query").should == true
	end

	it 'should use the cache' do
		cache = {}
		@wikipedia_client.extend(::VocabulariSe::WikipediaExt::Cache)                              
		@wikipedia_client.cache = cache
		@wikipedia_client.hit_counter = @counter

		result = @wikipedia_client.request_page "Love"
		cache.empty?.should == false
	end
end

