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
require 'vocabularise/queue_manager'
require 'vocabularise/request_manager'

require 'mendeley'
require 'wikipedia'

#$DEBUG = true
#$VERBOSE= true

module VocabulariSe

	json = JSON.load File.open 'config/vocabularise.json'
	config = VocabulariSe::Config.new json

	qman = QueueManager.new config
	qman.run

	rman = RequestManager.new config

	puts "Algo I"
	print "tag ? "
	STDOUT.flush
	intag = STDIN.gets.strip

	#related_tags = VocabulariSe::Utils.related_tags config, intag
	related_tags = rman.request RequestManager::REQUEST_RELATED, intag

	sleep 10

	algo = ExpectedAlgorithm.new config
	result = algo.exec intag, related_tags

	puts "AlgoI - result :"
	pp result
	pp JSON.generate(result)
end

