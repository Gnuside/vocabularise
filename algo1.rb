#!/usr/bin/ruby

$DEBUG = true
$VERBOSE= true

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


json = JSON.load File.open 'config.json'
config = VocabulariSe::Config.new json

puts "Algo I"
print "tag ? "
intag = STDIN.gets.strip

Indent.more


# Association audacieuse
workspace = {}
documents = Set.new
related_tags = VocabulariSe::Utils.related_tags config, intag
related_tags.each do |reltag|
	# sum of views for all documents
	views = 1
	apparitions = 0

	hit_count = 0
	limit = 5
	VocabulariSe::Utils.related_documents_multiple config, [intag, reltag] do |doc|
		views += doc.readers(config.mendeley_client)
		apparitions += 1

		# limit to X real hits
		hit_count += 1 unless doc.cached?
		puts "Algo - hit_count = %s" % hit_count
		break if hit_count > limit
	end
	slope =  apparitions.to_f / views.to_f
	workspace[reltag] = {
		:views => views,
		:apparitions => apparitions,
		:slope => slope
	}
end

puts "AlgoI - all tags :"
pp workspace.keys

# sort workspace keys (tags) by slope
result = workspace.sort{ |a,b| a[1][:slope] <=> b[1][:slope] }

# FIXME : limit to 3 or 5 results only
pp result[0..4]

