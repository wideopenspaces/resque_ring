require 'yaml'
require 'resque_ring/utilities/logger'

module ResqueRing
  class Manager
    # @return [Hash{Symbol => String}] the options
    #   used to create the Manager
    attr_reader :options

    # @return [Integer] the time between script runs
    attr_reader :delay

    # @return [Hash{String => WorkerGroup}] list of {WorkerGroup}s
    #   the manager manages, organized by name
    attr_reader :worker_groups

    # @return [Registry] the backend store used for keeping
    #   track of workers
    attr_reader :registry

    # @param options [Hash] options for the Manager, usually
    #   including a key called config containing
    #   the location of the config file.
    # @return [Object] a new instance of Manager
    def initialize(options = {})
      @options        = options
      @worker_groups  = {}

      load_config_file(options[:config])

      prepare_registry
      prepare_resque
      prepare_logger(options[:logfile])
    end

    def retire!
      worker_groups.each_value do |wg|
        wg.retire!
      end
    end

    def run!
      manage!
      sleep delay
    end

    # Instructs each WorkerGroup to manage its own workers
    # by calling {WorkerGroup#manage!}
    def manage!
      Utilities::Logger.info 'Time to make the donuts'
      worker_groups.each_value { |wg| wg.manage! }
    end

    private

    # Loads the contents of a YAML config file
    # @param config [String] a string representing the location of
    #   the config file
    def load_config_file(config)
      @config_file ||= Yambol.load_file(config) if config
      if @config_file
        set_delay(@config_file[:delay])
        set_worker_groups(@config_file[:workers])
        set_redis(@config_file[:redis])
      else
        set_redis({}) # use default Redis config
      end
    end

    # Loads redis with the proper options for redis
    # @param redis_options [Hash] a hash containing the host
    #   and port of the redis server
    # @return [Redis] a redis instance
    def load_redis(redis_options)
      unless redis_options.is_a?(Hash) && redis_options.keys.include?([:host, :port])
        redis_options = { host: 'localhost', port: 6379 }
      end
      @redis = Redis.new(redis_options)
    end

    def prepare_logger(logfile = nil)
      Utilities::Logger.logfile(logfile)
    end

    # Creates a new registry
    # @return [RedisRegistry] a RedisRegistry instance
    def prepare_registry
      @registry = RedisRegistry.new(@redis)
    end

    # Sets the Redis instance for Resque
    def prepare_resque
      Resque.redis = @redis
    end

    # Sets the time the script waits before calling #run! again
    # @param delay [Integer] time to wait, in seconds
    def set_delay(delay)
      @delay = delay || 120
    end

    def set_redis(redis_options)
      @redis = load_redis(redis_options)
    end

    # Instantiates and collects new WorkerGroups based on config
    # @param groups [Hash] a hash with names and options
    def set_worker_groups(groups)
      groups.each do |name, options|
        @worker_groups[name] = WorkerGroup.new(name, options.merge(manager: self))
      end
    end
  end
end

