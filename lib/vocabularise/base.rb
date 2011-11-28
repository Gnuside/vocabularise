
require 'vocabularise/config'
require 'vocabularise/crawler'

# load various handlers
require 'vocabularise/internal_handler'
require 'vocabularise/expected_handler'
require 'vocabularise/controversial_handler'
require 'vocabularise/aggregating_handler'
require 'vocabularise/wikipedia_handler'
require 'vocabularise/mendeley_handler'


module VocabulariSe

	class Base < ::Sinatra::Base

		enable :sessions
		enable :run

		set :haml, :format => :html5 # default Haml format is :xhtml

		set :static, true
		set :public_folder, File.expand_path( File.dirname(__FILE__) + '/../../static' )
		set :views, File.expand_path( File.dirname(__FILE__) + '/../../templates' )

		mime_type :ttf, "application/octet-stream"
		mime_type :eot, "application/octet-stream"
		mime_type :otf, "application/octet-stream"
		mime_type :woff, "application/octet-stream"

		helpers Sinatra::ContentFor


		# Common configuration
		configure do
			# set config
			json = JSON.load File.open 'config/vocabularise.json'
			config = VocabulariSe::Config.new json
			# set crawler
			crawler = VocabulariSe::Crawler.new config

			set :crawler, crawler
			set :config, config

			# run crawler thread ;-)
			crawler.run
		end


		# Static page
		get "/about" do
			@title = "About"
			haml :page_about
		end


		# Static page
		get "/news" do
			@title = "News"
			haml :page_news
		end


		# Static page
		get "/credits" do
			@title = "Credits"
			haml :page_credits
		end

		#
		# Index page
		get "/" do
			@title = "Index"
			haml :page_index
		end


		# Return the result page for given search expression
		get "/search" do
			# FIXME: use cache for search
			@query = params[:query]
			@title = @query

			if @query.empty? then 
				redirect '/'
			end

			begin
				settings.crawler.request \
					HANDLE_INTERNAL_RELATED_TAGS, 
					{ "tag" => @query },
					Queue::PRIORITY_HIGH

			rescue Crawler::DeferredRequest
				# does not hurt ;-)
			end

			haml :page_search
		end

		# Show request queue
		get "/status/queue" do
			haml :page_queue
		end


		# Show current cache
		get "/status/cache" do
			haml :page_cache
		end


		# Return results for expected algorithm
		get "/search/expected" do
			@query = params[:query]

			begin
				result = settings.crawler.request \
					HANDLE_INTERNAL_EXPECTED,
					{ "tag" => @query }, 
					Queue::PRIORITY_HIGH

=begin
			result = settings.manager.request :expected, @query
			if result.nil? then
				status(503)
			else
				JSON.generate( {
=end
				JSON.generate( { 
					:algorithm => "expected",
					:result => result
				} )
			rescue Crawler::DeferredRequest
				status(503)
			end
		end


		# Return results for aggregating algorithm
		get "/search/controversial" do
			@query = params[:query]

			begin
				result = settings.crawler.request \
					HANDLE_INTERNAL_CONTROVERSIAL,
					{ "tag" => @query },
					Queue::PRIORITY_HIGH

=begin
			result = settings.manager.request :controversial, @query
			if result.nil? then
				status(503)
			else
				JSON.generate( {
=end
				JSON.generate( { 
					:algorithm => "controversial",
					:result => result
				} )
			rescue Crawler::DeferredRequest
				status(503)
			end
		end


		# Return information about wikipedia pages for tag tag :tag
		get "/search/aggregating" do
			@query = params[:query]

			begin
				result = settings.crawler.request \
					HANDLE_INTERNAL_AGGREGATING,
					{ "tag" => @query },
					Queue::PRIORITY_HIGH

=begin
			result = settings.manager.request :aggregating, @query
			if result.nil? then
				status(503)
			else
				JSON.generate( {
=end
				JSON.generate( { 
					:algorithm => "aggregating",
					:result => result
				} )
			rescue Crawler::DeferredRequest
				status(503)
			end
		end


	end

end
