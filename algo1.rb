#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

$:.unshift 'lib'

require 'pp'

require 'rubygems'
require 'json'

require 'common/indent'
require 'vocabularise/config'
require 'vocabularise/cache'
require 'vocabularise/utils'
require 'vocabularise/excepted_algorithm'

require 'mendeley'
require 'wikipedia'

json = JSON.load File.open 'config/vocabularise.json'
config = VocabulariSe::Config.new json

puts "Algo I"
print "tag ? "
intag = STDIN.gets.strip

algo = VocabulariSe::ExceptedAlgorithm.new config
result = algo.exec "ionizing radiation"

pp result[0..4]
pp JSON.generate(result[0..4])

