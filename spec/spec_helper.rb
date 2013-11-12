# Coverage
if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec"
  end
end

# Load testing libraries
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest-spec-context'
require 'mocha/setup'

# Load utility libraries
require 'pry'
require 'yaml'

# Load myself
require 'resqued'

# Mock out all Redis calls
require 'mock_redis'
MOCK_REDIS = MockRedis.new
Redis.stubs(:new).returns(MOCK_REDIS)
