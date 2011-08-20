#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

require 'pp'

require 'rubygems'
#require 'sinatra'
require 'json'

require 'vocabulari-se/config'
require 'vocabulari-se/cache'
require 'vocabulari-se/utils'
require 'mendeley'
require 'wikipedia'

json = JSON.load File.open 'config.json'
config = VocabulariSe::Config.new json

intag = STDIN.gets.strip


# Association audacieuse
workspace = {}
documents = Set.new
related_tags = VocabulariSe::Utils.related_tags config, intag
related_tags.each do |reltag|
	# sum of views for all documents
	views = 0
	apparitions = 0
	VocabulariSe::Utils.related_documents config, [intag, reltag] do |doc|
		views += 1
		apparitions += 1
	end
	slop = views / apparitions
	workspace[reltag] = {
		:views => views,
		:apparitions => apparitions,
		:slope => slope
	}
end
pp workspace

# FIXME : sort workspace keys (tags) by slope
result = workspace.sort{ |a,b| a[:slope] <=> b[:slope] }

# FIXME : limit to 3 or 5 results only
pp result

