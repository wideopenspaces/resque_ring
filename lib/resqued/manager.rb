require 'yaml'

module Resque
  module Plugins
    module Resqued
      class Manager
        # @!attribute [r] options
        #   @return [Hash{Symbol => String}] the options
        #     used to create the Manager
        #
        # @!attribute [r] delay
        #   @return [Integer] the time between script runs
        #
        # @!attribute [r] worker_groups
        #   @return [Hash{String => WorkerGroup}] the groups
        #     the manager manages, organized by name
        #
        # @!attribute [r] registry
        #   @return [Registry] the backend store used for keeping
        #     track of workers
        attr_reader :options, :delay, :worker_groups, :registry

        # @param options [Hash] options for the Manager, usually
        #   including a key called config containing
        #   the location of the config file.
        # @return [Object] a new instance of Manager
        def initialize(options = {})
          @options = options
          @worker_groups = {}
          load_registry(options.delete(:redis))

          config = load_config_file(options[:config]) if options[:config]
        end

        # Kicks off the manage cycle, sleeps, and then
        # calls {Manager#run! itself} again
        def run!
          manage!
          # sleep delay
          # run!
        end

        # Instructs each WorkerGroup to manage its own workers
        # by calling {WorkerGroup#manage!}
        def manage!
          worker_groups.each_value { |wg| wg.manage! }
        end

        private

        # Loads the contents of a YAML config file
        # @param config [String] a string representing the location of
        #   the config file
        def load_config_file(config)
          @config_file ||= Yambol.load_file(config)
          if @config_file
            set_delay(@config_file[:delay])
            set_worker_groups(@config_file[:workers])
          end
        end

        # Loads the registry with the proper options for redis
        # @param redis_options [Hash] a hash containing the host
        #   and port of the redis server
        def load_registry(redis_options)
          unless redis_options.is_a?(Hash) && redis_options.keys.include?(:host, :port)
            redis_options = { host: 'localhost', port: 6379 }
          end
          @registry = RedisRegistry.new(redis_options)
        end

        # Sets the time the script waits before calling #run! again
        # @param delay [Integer] time to wait, in seconds
        def set_delay(delay)
          @delay = delay || 120
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
  end
end

