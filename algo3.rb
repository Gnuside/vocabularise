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

json = JSON.load File.open 'config.json'
config = VocabulariSe::Config.new json

puts "Algo III"
print "tag ? "
intag = STDIN.gets.strip

Indent.more


# Association audacieuse
tag_ws = {}

Hash.new({
	:ref => nil,
	:value => 0,
	:count => 0
})

documents = Set.new
related_tags = VocabulariSe::Utils.related_tags config, intag
puts "Algo III - related tags"
pp related_tags

related_tags.each do |reltag,reltag_count|
	# sum of views for all documents
	views = 1
	apparitions = reltag_count

	hit_count = 0
	limit = 2
	# reset discipline ws
	discipline_ws = {}

	# ws de disciplines
	begin
	VocabulariSe::Utils.related_documents_multiple config, [intag, reltag] do |doc|
		# FIXME: lister les disciplines du document
		# pour chaque discipline :
		#  * ajouter les % de readers
		#  * incrément de la discipline
		disciplines = doc.disciplines(config.mendeley_client)
		#pp disciplines

		disciplines.each do |disc|
			disc_name = disc["name"].to_s
			disc_id = disc["id"].to_i
			disc_value = disc["value"].to_i

			discipline_ws[disc_name] ||= { :value => 0, :count => 0 }
			discipline_ws[disc_name][:value] += disc_value
			discipline_ws[disc_name][:count] += 1

			#puts "  * %s " % disc.inspect
			#puts "ws:"
			#pp discipline_ws
		end
		# FIXME : associer à chaque tag les disciplines trouvées

		# limit to X real hits
		hit_count += 1 #unless doc.cached?
		puts "Algo - hit_count = %s" % hit_count
		break if hit_count > limit
	end
	rescue Mendeley::Client::RateLimitExceeded => e
		next
	end

	sorted_discipline_ws = discipline_ws.sort do |a,b|
		a_reader_avg = a[1][:value].to_f / a[1][:count].to_f
		b_reader_avg = b[1][:value].to_f / b[1][:count].to_f
		a_reader_avg <=> b_reader_avg
	end.reverse
	major_discipline = sorted_discipline_ws[0][0]
	pp sorted_discipline_ws
	puts "major_discipline = %s" % major_discipline

	sorted_discipline_ws.shift
	tag_ws[reltag] = { 
		:disc_list => sorted_discipline_ws,
		:disc_count => sorted_discipline_ws.size,
		:disc_sum => sorted_discipline_ws.inject(0){ |acc,x| 
			acc + x[1][:value].to_f / x[1][:count].to_f 
		}.to_i
	}

end

puts "AlgoIII - all disciplines :"
pp tag_ws
#.keys

puts "AlgoIII - sorted tags (by count then by sum) :"
# sort ws keys (tags) by increasing slope 
result = tag_ws.sort{ |a,b| 
	if a[1][:disc_count] == b[1][:disc_count] then
		a[1][:disc_sum] <=> b[1][:disc_sum]
	else
		a[1][:disc_count] <=> b[1][:disc_count]
	end
}.reverse

# FIXME : limit to 3 or 5 results only
pp result[0..4].map{ |x| x[0] }


