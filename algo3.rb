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
require 'vocabularise/generic_algorithm'
require 'vocabularise/aggregating_algorithm'

require 'mendeley'
require 'wikipedia'

json = JSON.load File.open 'config/vocabularise.json'
config = VocabulariSe::Config.new json

puts "Algo III"
print "tag ? "
STDOUT.flush
intag = STDIN.gets.strip

algo = VocabulariSe::AggregatingAlgorithm.new config
related_tags = VocabulariSe::Utils.related_tags config, intag
result = algo.exec intag, related_tags

# FIXME : limit to 3 or 5 results only
#pp result[0..4].map{ |x| x[0] }
pp JSON.generate(result[0..4])

exit 0
