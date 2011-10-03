
require 'fileutils'
require 'test/unit'
require 'pp'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'json'

require 'wikipedia'
require 'vocabularise/wikipedia'

describe 'WikipediaFix' do

	before :all do
		@wikipedia_client = Wikipedia::Client.new                           
		@wikipedia_client.extend(VocabulariSe::WikipediaFix)                              
		@wikipedia_client.cache = {}
	end
	
	it 'should search' do
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
end

