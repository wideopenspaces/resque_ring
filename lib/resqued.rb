$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'resque'
require 'resque/server'

require 'hattr_accessor/hattr_accessor'
require 'yambol'

require 'resqued/worker'
require 'resqued/pool'
require 'resqued/worker_group'
require 'resqued/manager'
require 'resqued/version'

# module Resqued
#   # Your code goes here...
# end
