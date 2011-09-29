
# use config from bundler
require "bundler/capistrano"

# use multi-stages
set :default_stage, "development"
set :stages, %w(production development)
require 'capistrano/ext/multistage'

set :application, "vocabularise"
set :repository,  "git@devel.gnuside.com:vocabulari-se.git"
set :branch, "master"

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
set :scm_verbose, true

# limit number of releases on server
set :keep_releases, 5


# To disable asset timestamps updates (javascript, stylesheets, etc.)
set :normalize_asset_timestamps, false


# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
	task :start, :roles => [:web, :app] do
		run "echo $PATH"
		run "cd #{deploy_to}/current && nohup bundle exec thin -C config/thin_#{deploy_env}.yml -R config.ru start"
	end

	task :stop, :roles => [:web, :app] do
		run "cd #{deploy_to}/current && nohup bundle exec thin -C config/thin_#{deploy_env}.yml -R config.ru stop"
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

	task :finalize_update, :roles => [:wep, :app] do
		unless File.exist? "#{shared_path}/config/vocabularise.json"
			run "cp #{current_release}/config/vocabularise.json.example #{shared_path}/config/vocabularise.json "
		end
		run "ln -s #{shared_path}/config/vocabularise.json #{current_release}/config/vocabularise.json"
	end

end

