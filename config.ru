
$:.push File.join( File.dirname(File.expand_path(__FILE__)), "/lib")

require 'rubygems'

# use bundler
require 'bundler/setup'

require 'sinatra/base'

require 'dm-core'
require 'dm-validations'
require 'dm-sqlite-adapter'


require "vocabularise/base"

run VocabulariSe::Base
