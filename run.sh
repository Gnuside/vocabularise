#!/bin/sh

export RUBYLIB=`pwd`/../Ruby-Spore/lib:lib
#bundle exec rackup config.ru -o 0.0.0.0 -p 9393
ruby algo1.rb
#ruby algo2.rb
#ruby algo3.rb
#bundle exec rackup config.ru -o 127.0.0.1 -p 9001
#bundle exec rackup config.ru -p 9393

# For real production :
#   thin -C thin-prod.yml -R config.ru start

# For development with other constraints 
#   shotgun config.ru -o 0.0.0.0 -p 9393
