
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

			# FIXME: run the crawler process
			# set :crawler, crawler 
			set :config, config
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

			# FIXME: add delayed job there
			# settings.crawler.request 
			#	HANDLE_INTERNAL_RELATED_TAGS, 
			#	{ "tag" => @query },
			#	Queue::PRIORITY_HIGH

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
		get "/search/expected.json" do
			@query = params[:query]
			@timestamp = params[:timestamp]

			begin
				# FIXME: verify that job is done
				# result = settings.crawler.request \
				#	HANDLE_INTERNAL_EXPECTED,
				#	{ "tag" => @query }, 
				#	Queue::PRIORITY_HIGH
				result = {}

				JSON.generate( { 
					:algorithm => "expected",
					:result => result
				} )
			rescue Crawler::DeferredRequest
				status(503)
			end
		end


		# Return results for aggregating algorithm
		get "/search/controversial.json" do
			@query = params[:query]
			@timestamp = params[:timestamp]

			begin
				# FIXME: verify that job is done
				# result = settings.crawler.request
				#	HANDLE_INTERNAL_CONTROVERSIAL,
				#	{ "tag" => @query },
				#	Queue::PRIORITY_HIGH

				JSON.generate( { 
					:algorithm => "controversial",
					:result => result
				} )
			rescue Crawler::DeferredRequest
				status(503)
			end
		end


		# Return information about wikipedia pages for tag tag :tag
		get "/search/aggregating.json" do
			@query = params[:query]
			@timestamp = params[:timestamp]

			begin
			# FIXME: verify that job is done
			#	result = settings.crawler.request \
			#		HANDLE_INTERNAL_AGGREGATING,
			#		{ "tag" => @query },
			#		Queue::PRIORITY_HIGH

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
