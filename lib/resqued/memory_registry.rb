module Resque
  module Plugins
    module Resqued
      class MemoryRegistry
        include Registry

        # @return [Registry]
        attr_reader :registry

        def initialize(options = {})
          @registry = {}
        end

        def reset!(namespace)
          @registry.delete_if { |k,v| k =~ /#{namespace}:/ }
        end

        def register(name, pid, options = {})
          atomically do
            sadd  "#{name}:worker_list", localize(pid)
            incr  "#{name}:worker_count"
            set   "#{name}:last_spawned", Time.now.utc
          end
        end

        def deregister(name, pid)
          atomically do
            decr  "#{name}:worker_count"
            srem  "#{name}:worker_list", localize(pid)
          end
        end

        def current(name, focus)
          get   "#{name}:#{focus}"
        end

        def list(name, focus)
          current(name, focus)
        end

        def atomically(&block)
          yield # use redis.multi in Redis version
        end

        def get(key)
          @registry.fetch(key, nil)
        end

        def set(key, value)
          @registry.store(key, value)
        end

        def sadd(key, value)
          @registry[key] ||= []
          @registry[key].push(value) unless @registry[key].include?(value)
        end

        def srem(key, value)
          @registry[key] ||= []
          @registry[key] = @registry[key] - [value]
        end

        def incr(key)
          @registry[key] ||= 0
          @registry[key] += 1
        end

        def decr(key)
          @registry[key] ||= 0
          @registry[key] -= 1
        end
      end
    end
  end
end