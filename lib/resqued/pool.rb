module Resque
  module Plugins
    module Resqued
      class Pool
        attr_reader :worker_group

        def initialize(options)
          @worker_group = options.delete('worker_group')
          @options = options
        end

        def first_at
          @options['first_at'] || 1
        end

        def global_max
          @options['global_max'] || 0
        end

        def manage!
          # despawn_if_necessary
          # spawn_if_necessary
        end

        def max
          @options['max'] || 5
        end

        def min
          @options['min'] || 1
        end
      end
    end
  end
end


