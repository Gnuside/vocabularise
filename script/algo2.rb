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
require 'vocabularise/controversial_algorithm'

require 'mendeley'
require 'wikipedia'

module VocabulariSe
	json = JSON.load File.open 'config/vocabularise.json'
	config = Config.new json
	algo = ControversialAlgorithm.new config

	crawler = Crawler.new config
	# set crawler
	config.mendeley_client.crawler = crawler

	#crawler.run

	puts "Algo II"
	print "tag ? "
	STDOUT.flush
	intag = STDIN.gets.strip

	related_tags = VocabulariSe::Utils.related_tags config, intag
	result = algo.exec intag, related_tags

	puts "AlgoII - result :"
	pp JSON.generate(result[0..4])

	exit 0
end
