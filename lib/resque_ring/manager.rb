require 'resque_ring/utilities/logger'
require 'resque_ring/config'

module ResqueRing
  # Manages the operations of ResqueRing by loading configuration
  # and telling appropriate worker groups when to manage themselves.
  class Manager
    attr_reader :cfg

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

    attr_reader :logger

    # attr_reader :signals

    attr_accessor :paused

    # $signals = []

    # @param options [Hash] options for the Manager, usually
    #   including a key called config containing
    #   the location of the config file.
    # @return [Object] a new instance of Manager
    def initialize(options = {})
      @options        = options
      @worker_groups  = {}

      load_config(options[:config])

      prepare_registry
      prepare_resque
      prepare_logger(options[:logfile])
    end

    # Instructs each WorkerGroup to manage its own workers
    # by calling {WorkerGroup#manage!}
    def manage!
      Utilities::Logger.debug 'Time to make the donuts'
      each_worker_group { |wg| wg.manage! } unless paused?
    end

    # Instructs each WorkerGroup to shut down its workers
    # by calling {WorkerGroup#retire!}
    #
    # Note this is a graceful exit and may take
    # some time to shut down, as it waits
    # for workers to finish their current task.
    def downsize!
      each_worker_group { |wg| wg.downsize! }
    end

    def pause!
      @paused = true
    end

    def continue!
      @paused = false
    end

    # Instructs WorkerGroups to manage & review workers
    # and then waits a configurable amount of time
    def run!
      manage! unless paused?
    end

    # Have we been paused?
    # @return [Boolean] current pause state
    def paused?
      @paused == true
    end

    private

    # Provides a block for easy interaction with all
    # of the worker_groups
    def each_worker_group
      worker_groups.each_value { |wg| yield(wg) }
    end

    # Loads the config & sets global options
    # @param config [String] a string representing the location of
    #   the config file
    def load_config(config)
      # @config_file ||= Yambol.load_file(config) if config
      @cfg = ResqueRing::Config.new(config)
      if cfg.loaded?
        set_delay(cfg.delay)
        set_worker_groups(cfg.workers)
        set_redis(cfg.redis)
      else
        set_redis({}) # use default Redis config
      end
    end

    def prepare_logger(logfile = nil)
      @logger = Utilities::Logger.logfile(logfile)
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
      @delay = delay
    end

    # Loads redis with the proper options for redis
    # @param redis_options [Hash] a hash containing the host
    #   and port of the redis server
    # @return [Redis] a redis instance
    def set_redis(redis_options)
      @redis = Redis.new(redis_options)
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
