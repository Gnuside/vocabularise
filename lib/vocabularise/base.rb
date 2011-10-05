
require 'vocabularise/config'
require 'vocabularise/request_manager'

module VocabulariSe

	class Base < ::Sinatra::Base

		enable :sessions
		enable :run

		set :haml, :format => :html5 # default Haml format is :xhtml

		set :static, true
		set :public, File.expand_path( File.dirname(__FILE__) + '/../../static' )
		set :views, File.expand_path( File.dirname(__FILE__) + '/../../templates' )

		mime_type :ttf, "application/octet-stream"
		mime_type :eot, "application/octet-stream"
		mime_type :otf, "application/octet-stream"
		mime_type :woff, "application/octet-stream"

		helpers Sinatra::ContentFor


		# Common configuration
		configure do
			json = JSON.load File.open 'config/vocabularise.json'
			config = VocabulariSe::Config.new json
			manager = VocabulariSe::RequestManager.new config
			set :config, config
			set :manager, manager
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

			settings.manager.request :related, @query

			haml :page_search
		end

		# Show request queue
		get "/status/request_queue" do
			haml :page_request_queue
		end


		# Show current cache
		get "/status/cache" do
			haml :page_cache
		end


		# Return results for expected algorithm
		get "/search/expected" do
			@query = params[:query]

			result = settings.manager.request :expected, @query
			if result.nil? then
				status(503)
			else
				JSON.generate( {
					:algorithm => "expected",
					:result => result
				} )
			end
		end


		# Return results for aggregating algorithm
		get "/search/controversial" do
			@query = params[:query]

			result = settings.manager.request :controversial, @query
			if result.nil? then
				status(503)
			else
				JSON.generate( {
					:algorithm => "controversial",
					:result => result
				} )
			end

		end


		# Return information about wikipedia pages for tag tag :tag
		get "/search/aggregating" do
			@query = params[:query]

			result = settings.manager.request :aggregating, @query
			if result.nil? then
				status(503)
			else
				JSON.generate( {
					:algorithm => "aggregating",
					:result => result
				} )
			end
		end


	end

end
