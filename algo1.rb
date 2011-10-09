#!/usr/bin/ruby
# vim: set ts=4 sw=4 noet path+=lib :
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
require 'vocabularise/request_handler'
require 'vocabularise/internal_handler'
require 'vocabularise/expected_handler'

require 'mendeley'
require 'wikipedia'

#$DEBUG = true
#$VERBOSE= true

module VocabulariSe

	json = JSON.load File.open 'config/vocabularise.json'
	config = VocabulariSe::Config.new json

	crawler = Crawler.new config
	# set crawler
	config.mendeley_client.crawler = crawler

	crawler.run

	puts "Algo I"
	print "tag ? "
	STDOUT.flush
	intag = STDIN.gets.strip

	#related_tags = VocabulariSe::Utils.related_tags config, intag
	related_tags = nil
	loop do
		begin
			related_tags = crawler.request HANDLE_INTERNAL_RELATED_TAGS, 
				intag, 
				Crawler::MODE_INTERACTIVE
			break
		rescue Crawler::DeferredRequest
			# wait...
			sleep 1
		end
	end

	algo = ExpectedAlgorithm.new config
	result = algo.exec intag, related_tags
	pp result
	exit 1

	puts "AlgoI - result :"
	pp result
	pp JSON.generate(result)
end

