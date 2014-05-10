# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

# Resque
require 'resque'
require 'resque/server'

# Gem-based libraries
require 'yambol'
require 'madhattr/hattr_accessor'

# Extensions to core classes
require 'core/ext'

# ResqueRing!
require 'resque_ring/utilities/logger'
require 'resque_ring/globals'
require 'resque_ring/runner'
require 'resque_ring/worker'
require 'resque_ring/pool'
require 'resque_ring/registry'
require 'resque_ring/redis_registry'
require 'resque_ring/queue'
require 'resque_ring/queue_group'
require 'resque_ring/worker_group'
require 'resque_ring/config'
require 'resque_ring/manager'
require 'resque_ring/version'
