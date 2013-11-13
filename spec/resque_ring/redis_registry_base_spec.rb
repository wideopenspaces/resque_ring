require 'spec_helper'
require 'resque_ring/redis_registry'

describe ResqueRing::RedisRegistry do
  let(:registry)    { ResqueRing::RedisRegistry.new(Redis.new) }
  let(:prefix)      { "#{ResqueRing::RedisRegistry::PREFIX}:test" }

  before { registry.reset!('test') }

  it 'knows its own host' do
    registry.host.must_equal(`hostname`.strip)
  end

  context 'reset!' do
    before do
      MOCK_REDIS.set("#{prefix}:my_fake_key", 42)
      MOCK_REDIS.set("#{prefix}:another_key", 42)
      registry.reset!('test')
    end

    it 'clears all keys in a given namespace' do
      MOCK_REDIS.keys("#{prefix}:*").must_be_empty
    end
  end

  context '#register' do
    before { registry.register('test', '1234', {}) }

    it 'adds the worker to worker_list' do
      registry.list('test', 'worker_list').must_include("#{registry.host}:1234")
    end

    it 'increases the worker count' do
      registry.current('test', 'worker_count').must_equal('1')
    end

    it 'sets last_spawned' do
      registry.current('test', 'last_spawned').wont_be_nil
    end

    it 'blocks new spawns' do
      registry.current('test', 'spawn_blocked').must_equal('1')
    end
  end

  context '#deregister' do
    before do
      registry.register('test', '1234', {})
      registry.deregister('test', '1234')
    end

    it 'decrements the worker count' do
      registry.current('test', 'worker_count').must_equal('0')
    end

    it 'removes the worker from the worker list' do
      registry.list('test', 'worker_list').wont_include("#{registry.host}:1234")
    end
  end

  context '#list' do
    before do
      MOCK_REDIS.sadd("#{prefix}:my_set", 'aa')
    end

    it 'gets the members of the appropriate set' do
      registry.list('test', 'my_set').must_include('aa')
    end
  end

  context '#current' do
    before do
      MOCK_REDIS.set("#{prefix}:my_key", 'fake')
    end

    it 'gets the value of the appropriate key' do
      registry.current('test', 'my_key').must_equal('fake')
    end
  end
end