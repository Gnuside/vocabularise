#!/usr/bin/ruby

require 'pp'

require 'rubygems'
#require 'sinatra'
require 'json'
require 'spore'
require 'spore/middleware/format'
require 'spore/middleware/cache'
require 'spore/middleware/useragent'

require 'vocabulari-se/cache'

CACHE_DIR = File.join( (File.dirname $0), '..' )
CONSUMER_KEY = "d0d46ad71eb6691a44fb608424ad71c704e160d23"
CONSUMER_SECRET = "4fb7cd67cd36e341be6966db0b4dd261"

cache = VocabulariSe::DirectoryCache.new "cache", (60 * 60 * 24)
mdl = Spore.new("mendeley.json")
mdl.enable(Spore::Middleware::Cache, :storage => cache )

#mdl.enable(Spore::Middleware::UserAgent, :useragent => 'Mozilla/5.0 (X11; Linux x86_64; rv:2.0b4) Gecko/20100818 Firefox/4.0b4')
#mdl.enable(Spore::Middleware::Format, :format => 'json')

#r = mdl.stats_authors( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#r = mdl.stats_papers( :consumer_key => CONSUMER_KEY, :discipline => 5 )
#r = mdl.stats_publications( :consumer_key => CONSUMER_KEY, :discipline => 5 )
r = mdl.stats_tags( :consumer_key => CONSUMER_KEY, :discipline => 5 )
pp r.body

r = mdl.stats_tags( :consumer_key => CONSUMER_KEY, :discipline => 5 )
pp r.body

