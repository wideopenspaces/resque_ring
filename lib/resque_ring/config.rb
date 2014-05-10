require 'yaml'
require 'core/ext/array'

module ResqueRing
  # Stores the configuration options for ResqueRing
  class Config
    extend Forwardable
    def_delegators :@config, :workers

    REDIS_KEYS    = [:host, :port]
    REDIS_DEFAULT = { host: 'localhost', port: 6379 }

    # @return [OpenStruct] the config as an OpenStruct
    attr_reader :config

    # @return [String] a string containing the path
    #   to the configuration file
    attr_reader :source_file

    # @param config_file [String] a string containing a
    # path to the desired configuration file
    # @return [Config] a configuration object
    def initialize(config_file)
      if config_file
        @source_file = config_file
        load
      end
    end

    # Has the configuration been loaded?
    # @return [Boolean]
    def loaded?
      config && config.is_a?(OpenStruct)
    end

    # Fetches delay between manager runs from config file
    # @return [Number] either the specified delay or 120 (the default)
    def delay
      loaded? && @config.delay ? @config.delay : 120
    end

    # Fetches redis options from the config file.
    # Returns default redis values if not set
    # @return [Hash] including keys for :host & :port
    def redis
      loaded? && redis_set? ? @config.redis : REDIS_DEFAULT
    end

    private

    def redis_set?
      @config.redis.is_a?(Hash) && @config.redis.keys?(:host, :port)
    end

    # Loads the config_file into an OpenStruct
    # @return [OpenStruct] the config file as a struct
    def load
      @config = OpenStruct.new(load_yml)
    end

    # Loads config file into a symbolized hash
    # @return [Hash] the config file as a hash
    def load_yml
      Yambol.load_file(source_file)
    end
  end
end
