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
require 'vocabularise/cache'
require 'vocabularise/utils'
require 'vocabularise/expected_algorithm'

require 'mendeley'
require 'wikipedia'

json = JSON.load File.open 'config/vocabularise.json'
config = VocabulariSe::Config.new json

puts "Algo I"
print "tag ? "
intag = STDIN.gets.strip

related_tags = VocabulariSe::Utils.related_tags config, intag
algo = VocabulariSe::ExpectedAlgorithm.new config
result = algo.exec intag, related_tags

puts "AlgoI - result :"
pp result
pp JSON.generate(result)

