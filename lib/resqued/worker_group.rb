module Resque
  module Plugins
    module Resqued
      class WorkerGroup
        attr_reader :name

        def initialize(name, options = {})
          @name = name
          @options = options
        end

        def queues
          @options['queues'] || []
        end

        def spawn_rate
          @options['spawn_rate'] || 1
        end

        def threshold
          @options['threshold'] || 100
        end

        def wait_time
          @options['wait_time'] || 60
        end

        def pool
          @pool ||= Resque::Plugins::Resqued::Pool.new(@options['pool'])
        end
      end
    end
  end
end