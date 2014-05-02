module ResqueRing
  # Methods for storing and retrieving ResqueRing information via Redis
  class RedisRegistry
    include Registry

    PREFIX = 'resque_ring'

    extend Forwardable
    def_delegators :@redis, :get, :set, :sadd, :srem, :incr, :decr
    def_delegators :@redis, :hget, :hset, :hincrby, :hincrbyfloat

    # @param redis_instance [Redis] a Redis instance, or something entirely compatible
    def initialize(redis_instance)
      @redis = redis_instance
    end

    # Deletes all our keys associated with namespace from Redis.
    # Useful in tests and when starting fresh.
    # @param namespace [String] usually {WorkerGroup#name}
    def reset!(namespace)
      @redis.keys(_key(namespace, '*')).each { |k| @redis.del(k) }
    end

    # Registers a new {Worker} instance into Redis by storing its
    # PID, incrementing the total count of workers, recording the
    # time of spawn and setting a key to block spawning until expired.
    # @param name     [String] usually {WorkerGroup#name}
    # @param pid      [Integer] the PID of the {Worker} process
    # @param options  [Hash] a hash containing additional options
    # @option options [Integer] :delay How long spawning is blocked.
    #   this information comes from {WorkerGroup#wait_time}
    def register(name, pid, options = {})
      atomically do |multi|
        multi.sadd  _key(name, 'worker_list'), localize(pid)
        multi.incr  _key(name, 'worker_count')
        multi.set   _key(name, 'last_spawned'), Time.now.utc
        multi.setex _key(name, 'spawn_blocked'), options.fetch(:delay, 120), 1
      end
    end

    # De-registers a {Worker} instance identified by pid from Redis by
    # decrementing worker_count and removing the worker from the list
    # of workers
    # @param name [String]  usually {WorkerGroup#name}
    # @param pid  [Integer] the the PID of the {Worker} process
    def deregister(name, pid)
      atomically do |multi|
        multi.decr  _key(name, 'worker_count')
        multi.srem  _key(name, 'worker_list'), localize(pid)
      end
    end

    # Gets the members of a Redis Set
    # @param name   [String]  usually {WorkerGroup#name}
    # @param focus  [String]  the redis key for the Set
    # @return [Array] the members of the Set
    def list(name, focus)
      @redis.smembers _key(name, focus)
    end

    # Gets the contents of a simple Redis key
    # @param name   [String]  usually {WorkerGroup#name}
    # @param focus  [String]  the redis key
    # @return       [String]  the contents of the key
    def current(name, focus)
      get _key(name, focus)
    end

    # Perform operations within block in a Redis transaction
    # @yieldparam multi [Redis::Multi] a Redis.multi context (for atomic operations)
    def atomically(&block)
      @redis.multi { |multi| yield multi }
    end

    private

    def _key(namespace, key)
      [PREFIX, namespace, key].join(':')
    end
  end
end
