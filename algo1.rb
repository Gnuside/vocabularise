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

algo = VocabulariSe::ExceptedAlgorithm.new config
algo.exec "ionizing radiation"


