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

	score = 0
	limit = ARTICLE_LIMIT
	resp["query"]["search"].each do |article_desc|
		talk_title = "Talk:%s" % article_desc["title"]
		puts "  - " + talk_title
		#pp article_desc
		page_json = config.wikipedia_client.request_page talk_title
		begin
			page = Wikipedia::Page.new page_json
			raw = page.content
		rescue Timeout::Error => e
			puts "  WARNING: timeout error"
			next
		end
		#puts raw
		titles = (raw.split(/\n/) rescue []).select{ |line| line.strip =~ /^\s*==.*==\s*/ }
		score += titles.size
		#page.links.each { |tag| tags[tag] += 1 }

		limit -= 1
		break if limit <= 0
	end
	puts "  * score = %s" % score
	return score
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

	workspace[reltag] = {
		:hotness => hotness
	}
end

puts "AlgoII - all tags :"
pp workspace.keys

# sort workspace keys (tags) by slope
result = workspace.sort{ |a,b| a[1][:hotness] <=> b[1][:hotness] }.reverse

# FIXME : use archive pages if needed
# FIXME : limit to 3 or 5 results only
puts "AlgoII - result :"
pp result[0..4]

exit 0
