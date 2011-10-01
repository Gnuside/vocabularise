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
require 'vocabularise/controversial_algorithm'

require 'mendeley'
require 'wikipedia'

json = JSON.load File.open 'config/vocabularise.json'
config = VocabulariSe::Config.new json
algo = VocabulariSe::ControversialAlgorithm.new config

puts "Algo II"
print "tag ? "
intag = STDIN.gets.strip

related_tags = VocabulariSe::Utils.related_tags config, intag
result = algo.exec intag, related_tags

puts "AlgoII - result :"
pp JSON.generate(result[0..4])

exit 0

