require 'pry'
require 'yaml'

# require 'resque'
require 'resqued'

if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end

require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/hell'

require 'minitest-spec-context'

require 'mocha/setup'

# Uses the in-memory registry to replace RedisRegistry for testing
# RedisRegistry will NOT work with minitest/hell
#
# TODO: Add a test switch to test with redis
Resque::Plugins::Resqued::RedisRegistry = Resque::Plugins::Resqued::Registry