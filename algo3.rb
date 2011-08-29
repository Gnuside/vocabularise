#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

$:.unshift 'lib'

require 'pp'

require 'rubygems'
#require 'sinatra'
require 'json'

require 'common/indent'
require 'vocabulari-se/config'
require 'vocabulari-se/cache'
require 'vocabulari-se/utils'

require 'mendeley'
require 'wikipedia'


# limit the number of considered articles for computation
ARTICLE_LIMIT = 3
def tag_hotness config, tags_arr
	search_expr = tags_arr.sort.join(' AND ')
	puts search_expr

	resp_json =  config.wikipedia_client.search( search_expr )
	resp = JSON.parse resp_json

	limit = ARTICLE_LIMIT
	resp["query"]["search"].each do |article_desc|
		talk_title = "Talk:%s" % article_desc["title"]
		#pp article_desc
		puts "  - " + talk_title
		limit -= 1
		break if limit <= 0
	end
end

json = JSON.load File.open 'config.json'
config = VocabulariSe::Config.new json

puts "Algo II"
print "tag ? "
intag = STDIN.gets.strip


# Association audacieuse
workspace = {}
documents = Set.new
related_tags = VocabulariSe::Utils.related_tags config, intag
related_tags.each do |reltag,reltag_count|
	hotness = tag_hotness( config, [reltag, intag] )

	#workspace[reltag] = {
	#	:hotness => hotness
	#}
end
exit 1

puts "AlgoII - all tags :"
pp workspace.keys

# sort workspace keys (tags) by slope
result = workspace.sort{ |a,b| a[1][:slope] <=> b[1][:slope] }

# FIXME : limit to 3 or 5 results only
pp result[0..4]

