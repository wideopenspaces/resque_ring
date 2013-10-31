module Resque
  module Plugins
    module Resqued
      class Pool
        extend HattrAccessor

        attr_reader   :worker_group, :workers
        hattr_reader  :options, :first_at, :global_max, :max, :min

        def initialize(options)
          @workers = []
          @worker_group = options.delete(:worker_group)
          @options = defaults.merge(options)
        end

        def manage!
          # despawn_if_necessary
          # spawn_if_necessary
        end

        def register(pid)
          # store pid in redis
          # increment pool size
        end

        private

        def defaults
          {
            first_at:    1,
            global_max:  0,
            max:         5,
            min:         1
          }
        end

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


