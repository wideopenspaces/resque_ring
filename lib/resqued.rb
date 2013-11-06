$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'resque'
require 'resque/server'

require 'yambol'
require 'madhattr/hattr_accessor'

require 'resqued/worker'
require 'resqued/pool'
require 'resqued/registry'
require 'resqued/queue'
require 'resqued/worker_group'
require 'resqued/manager'
require 'resqued/version'

# module Resqued
#   # Your code goes here...
# end
