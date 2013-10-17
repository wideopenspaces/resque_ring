module Resque
  module Plugins
    module Resqued
      class Pool
        attr_reader :worker_group, :workers

        def initialize(options)
          @workers = []
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

        def register(pid)
          # store pid in redis
          # increment pool size
        end

        private

        def spawn!
          worker = Resque::Plugins::Resqued::Worker.new(worker_options)
          register(worker) if worker.alive?
        end

        def worker_options
          worker_group.worker_options.merge({ pool: self })
        end
      end
    end
  end
end


