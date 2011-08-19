#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

require 'pp'

require 'rubygems'
#require 'sinatra'
require 'json'

require 'vocabulari-se/cache'
require 'vocabulari-se/utils'
require 'mendeley'

config = JSON.load File.open 'config.json'
cache = VocabulariSe::DirectoryCache.new config["cache_dir"], (60 * 60 * 24)
client = Mendeley::Client.new( config["consumer_key"], cache )

#	r = mdl.stats_authors( :discipline => 5 )
#	r = mdl.stats_papers( :discipline => 5 )
#	r = mdl.stats_publications( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#	r = mdl.stats_tags( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#	r = mdl.document_search( :consumer_key => CONSUMER_KEY, :terms => "freedom" )
#	r = mdl.documents_search( :terms => "freedom", :page => 1 )


tags = VocabulariSe::Utils.related_tags "freedom"
pp tags

#JSON.parse r.body.content

#r = mdl.stats_tags( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#pp r.body

