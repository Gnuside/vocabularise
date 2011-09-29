
role :web, "market.gnuside.com"                          # Your HTTP server, Apache/etc
role :app, "market.gnuside.com"                          # This may be the same as your `Web` server
role :db,  "market.gnuside.com", :primary => true # This is where Rails migrations will run

set :user, "www-data"
set :use_sudo, false

set :deploy_to, "/home/data/www/com.gnuside/client.deuxiemelabo"
set :deploy_env, 'development'

