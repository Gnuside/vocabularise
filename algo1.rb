#!/usr/bin/ruby

$:.unshift 'lib'

require 'pp'

require 'rubygems'
require 'bundler/setup'

require 'json'

require 'common/indent'
require 'vocabularise/config'
require 'vocabularise/utils'
require 'vocabularise/expected_algorithm'
require 'vocabularise/crawler'
require 'vocabularise/request_manager'

require 'mendeley'
require 'wikipedia'

#$DEBUG = true
#$VERBOSE= true

module VocabulariSe

	json = JSON.load File.open 'config/vocabularise.json'
	config = VocabulariSe::Config.new json

	crawler = Crawler.new config
	crawler.run

	rman = RequestManager.new config

	puts "Algo I"
	print "tag ? "
	STDOUT.flush
	intag = STDIN.gets.strip

	#related_tags = VocabulariSe::Utils.related_tags config, intag
	related_tags = nil
	while related_tags.nil? do
		related_tags = crawler.request Crawler::REQUEST_RELATED, intag, Crawler::MODE_INTERACTIVE
		sleep 1
	end

	algo = ExpectedAlgorithm.new config
	result = algo.exec intag, related_tags

	puts "AlgoI - result :"
	pp result
	pp JSON.generate(result)
end

