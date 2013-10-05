$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'resque'
require 'resque/server'

require 'resqued/manager'
require 'resqued/version'

# module Resqued
#   # Your code goes here...
# end
