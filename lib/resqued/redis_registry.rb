module Resque
  module Plugins
    module Resqued
      class RedisRegistry < Registry
        PREFIX = 'resqued'

        extend Forwardable
        # Redis can handle these methods directly
        def_delegators :@redis, :get, :set, :sadd, :srem, :incr, :decr

        def initialize(redis_options)
          @redis = Redis.new(redis_options)
        end

        def reset!(namespace)
          @redis.keys(_key(namespace, '*')).each { |k| @redis.del(k) }
        end

        def register(name, pid, options = {})
          atomically do |multi|
            multi.sadd  _key(name, 'worker_list'), localize(pid)
            multi.incr  _key(name, 'worker_count')
            multi.set   _key(name, 'last_spawned'), Time.now.utc
            multi.setex _key(name, 'spawn_blocked'), options.fetch(:delay, 120), 1
          end
        end

        def deregister(name, pid)
          atomically do |multi|
            multi.decr  _key(name, 'worker_count')
            multi.srem  _key(name, 'worker_list'), localize(pid)
          end
        end

        def list(name, focus)
          @redis.smembers _key(name, focus)
        end

        def current(name, focus)
          get _key(name, focus)
        end

        def atomically(&block)
          @redis.multi { |multi| yield multi }
        end

        private

        def _key(namespace, key)
          [PREFIX, namespace, key].join(':')
        end
      end
    end
  end
end