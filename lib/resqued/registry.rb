module Resque
  module Plugins
    module Resqued
      class Registry
        @@host = `hostname`.strip

        attr_reader :registry

        def initialize
          @registry = {}
        end

        def host
          @@host
        end

        def register(name, pid)
          sadd  "#{name}:worker_list", localize(pid)
          incr  "#{name}:worker_count"
          set   "#{name}:last_spawned", Time.now.utc
        end

        def deregister(name, pid)
          decr  "#{name}:worker_count"
          srem  "#{name}:worker_list", localize(pid)
        end

        def current(name, focus)
          get   "#{name}:#{focus}"
        end

        def localize(value)
          "#{host}:#{value}"
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