#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

require 'pp'
require 'rubygems'
require 'json'
require 'mendeley'
require 'vocabulari-se/cache'

config = JSON.load File.open 'config.json'
cache = VocabulariSe::DirectoryCache.new config["cache_dir"], (60 * 60 * 24)
client = Mendeley::Client.new( config["consumer_key"], cache )

STDERR.print "input tag ? "
t0 = STDIN.gets

related_tags = Mendeley::Tag.related_tags client, t0
