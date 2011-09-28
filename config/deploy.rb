
require "bundler/capistrano"

set :application, "vocabularise"
set :repository,  "git@devel.gnuside.com:vocabulari-se.git"
set :branch, "master"

set :deploy_to, "/home/data/www/com.gnuside/client.deuxiemelabo"

set :scm, :git
set :scm_verbose, true

set :user, "www-data"
set :use_sudo, false

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "market.gnuside.com"                          # Your HTTP server, Apache/etc
role :app, "market.gnuside.com"                          # This may be the same as your `Web` server
role :db,  "market.gnuside.com", :primary => true # This is where Rails migrations will run

# To disable asset timestamps updates (javascript, stylesheets, etc.)
 set :normalize_asset_timestamps, false

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
	task :start, :roles => [:web, :app] do
		run "echo $PATH"
		run "cd #{deploy_to}/current && nohup bundle exec thin -C config/thin_production.yml -R config.ru start"
	end

	task :stop, :roles => [:web, :app] do
		run "cd #{deploy_to}/current && nohup bundle exec thin -C config/thin_production.yml -R config.ru stop"
	end

	task :restart, :roles => [:web, :app] do
		deploy.stop
		deploy.start
	end

	# This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
	task :cold do
		deploy.update
		deploy.start
	end
end

