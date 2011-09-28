
role :web, "market.gnuside.com"                          # Your HTTP server, Apache/etc
role :app, "market.gnuside.com"                          # This may be the same as your `Web` server
role :db,  "market.gnuside.com", :primary => true # This is where Rails migrations will run

set :deploy_to, "/home/www/vocabulari.se"
set :deploy_env, 'production'

