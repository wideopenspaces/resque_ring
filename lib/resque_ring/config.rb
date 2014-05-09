require 'yaml'

module ResqueRing
  # Stores the configuration options for ResqueRing
  class Config
    extend Forwardable
    def_delegators :@config, :workers

    # @return [OpenStruct] the config as an OpenStruct
    attr_reader :config

    # @return [String] a string containing the path
    #   to the configuration file
    attr_reader :config_file

    # @param config_file [String] a string containing a
    # path to the desired configuration file
    # @return [Config] a configuration object
    def initialize(config_file)
      if config_file
        @config_file = config_file
        load
      end
    end

    # Loads the config_file into an OpenStruct
    # @return [OpenStruct] the config file as a struct
    def load
      @config = OpenStruct.new(load_yml)
    end

    # Loads config file into a symbolized hash
    # @return [Hash] the config file as a hash
    def load_yml
      Yambol.load_file(config_file)
    end

    # Has the configuration been loaded?
    # @return [Boolean]
    def loaded?
      config && config.is_a?(OpenStruct)
    end

    def delay
      @config.delay || 120
    end

    def redis
      if @config.redis.is_a?(Hash) && @config.redis.keys.include?([:host, :port])
        @config.redis
      else
        { host: 'localhost', port: 6379 }
      end
    end
  end
end
