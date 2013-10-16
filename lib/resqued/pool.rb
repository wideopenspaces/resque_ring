module Resque
  module Plugins
    module Resqued
      class Pool
        def initialize(options)
          @options = options
        end

        def first_at
          @options['first_at'] || 1
        end

        def global_max
          @options['global_max'] || 0
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


