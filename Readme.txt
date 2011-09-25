h1. Vocabulari.se

h2. Requirements

First, make sure your system uses a proper version of rubygems 
(>= 1.7.x)

Then, install  headers packages required to build some gems

 sudo apt-get install libmysqlclient-dev \
 libsqlite3-dev

Install required gems into ''vendor/'' directory

 bundle install --path vendor
