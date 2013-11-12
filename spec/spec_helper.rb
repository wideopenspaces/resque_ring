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

require 'minitest-spec-context'

require 'mocha/setup'

# In tests, mock out all Redis calls
require 'mock_redis'
$mock_redis = MockRedis.new
Redis.stubs(:new).returns($mock_redis)
