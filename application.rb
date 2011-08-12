#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

require 'pp'

require 'rubygems'
#require 'sinatra'
require 'json'

require 'vocabulari-se/cache'
require 'mendeley'

CACHE_DIR = File.join( (File.dirname $0), '..' )
CONSUMER_KEY = "d0d46ad71eb6691a44fb608424ad71c704e160d23"
CONSUMER_SECRET = "4fb7cd67cd36e341be6966db0b4dd261"

#cache = VocabulariSe::DirectoryCache.new "cache", (60 * 60 * 24)
cache = VocabulariSe::DirectoryCache.new "cache", (60 * 60 * 24)
#cache = {}
mdl = Mendeley.new( CONSUMER_KEY, cache )

#	r = mdl.stats_authors( :discipline => 5 )
#	r = mdl.stats_papers( :discipline => 5 )
#	r = mdl.stats_publications( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#	r = mdl.stats_tags( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#	r = mdl.document_search( :consumer_key => CONSUMER_KEY, :terms => "freedom" )
#	r = mdl.documents_search( :terms => "freedom", :page => 1 )

def tags_related mdl, tag, &blk
	page = 0
	total_pages = 0
	while true do
		resp = mdl.documents_tagged( :tag => tag, :page => page )
		total_pages = resp["total_pages"]
		yield resp
		page += 1
		break if page >= total_pages
		sleep 1
	end
end

tags_related mdl, "freedom" do |resp|
	pp resp
end

#JSON.parse r.body.content

#r = mdl.stats_tags( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#pp r.body

