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
tag_workspace = {}
discipline_workspace = Hash.new({
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

	# workspace de disciplines
	VocabulariSe::Utils.related_documents_multiple config, [intag, reltag] do |doc|
		# FIXME: lister les disciplines du document
		# pour chaque discipline :
		#  * ajouter les % de readers
		#  * incrément de la discipline
		disciplines = doc.disciplines(config.mendeley_client)
		pp disciplines
=begin
		disciplines.each do |discipline|
			disc_name = discipline["name"]
			disc_id = discipline["id"]
			disc_value = discipline["value"]

			discipline_workspace[disc_name][:ref] ||= discipline
			discipline_workspace[disc_name][:value] += disc_value
			discipline_workspace[disc_name][:count] += 1
		end
		# FIXME : associer à chaque tag les disciplines trouvées
=end
		# limit to X real hits
		hit_count += 1 #unless doc.cached?
		puts "Algo - hit_count = %s" % hit_count
		break if hit_count > limit
	end
=begin
	slope =  apparitions.to_f / views.to_f
	tag_workspace[reltag] = {
		:views => views,
		:apparitions => apparitions,
		:slope => slope
	}
	exit 1
=end
end
exit 1

puts "AlgoIII - all disciplines :"
pp discipline_workspace
#.keys

exit 1
# sort workspace keys (tags) by increasing slope 
result = workspace.sort{ |a,b| a[1][:slope] <=> b[1][:slope] }.reverse

# FIXME : limit to 3 or 5 results only
pp result[0..4]


