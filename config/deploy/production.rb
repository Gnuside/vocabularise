
role :web, "vocabulari.se"                          # Your HTTP server, Apache/etc
role :app, "vocabulari.se"                          # This may be the same as your `Web` server
role :db,  "vocabulari.se", :primary => true # This is where Rails migrations will run

set :deploy_to, "/home/vocabularise"
set :deploy_env, 'production'

