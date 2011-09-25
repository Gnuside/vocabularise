
$:.push File.join( File.dirname(File.expand_path(__FILE__)), "/lib")

require 'rubygems'

# use bundler
require 'bundler/setup'

# Web App server 
require 'sinatra/base'

# Database
require 'dm-core'
require 'dm-validations'
require 'dm-sqlite-adapter'

# Rendering
require 'haml'

# Vocabularise specific
require "vocabularise/base"

run VocabulariSe::Base
