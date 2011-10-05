#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

$:.unshift 'lib'

require 'pp'

require 'rubygems'
require 'bundler/setup'

require 'json'

require 'common/indent'
require 'vocabularise/config'
require 'vocabularise/utils'
require 'vocabularise/crawler'
require 'vocabularise/generic_algorithm'
require 'vocabularise/aggregating_algorithm'

require 'mendeley'
require 'wikipedia'

module VocabulariSe
	json = JSON.load File.open 'config/vocabularise.json'
	config = Config.new json
	algo = AggregatingAlgorithm.new config

	crawler = Crawler.new config
	# set crawler
	config.mendeley_client.crawler = crawler

	puts "Algo III"
	print "tag ? "
	STDOUT.flush
	intag = STDIN.gets.strip

	related_tags = Utils.related_tags config, intag
	puts "Algo III - related tags"
	pp related_tags
	STDIN.gets
	result = algo.exec intag, related_tags

	# FIXME : limit to 3 or 5 results only
	#pp result[0..4].map{ |x| x[0] }
	pp JSON.generate(result[0..4])

	exit 0
end
