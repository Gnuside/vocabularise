
$:.push File.join( File.dirname(File.expand_path(__FILE__)), "lib")

# use bundler
require 'bundler/setup'

# Web App server 
require 'sinatra/base'
require 'sinatra/content_for'

# Database
require 'dm-core'
require 'dm-validations'
require 'dm-sqlite-adapter'

# Rendering
require 'haml'
require 'json'

# Vocabularise specific
require "vocabularise"

run VocabulariSe::Base

