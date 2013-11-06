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
          despawn_if_necessary
          spawn_if_necessary
        end

        def deregister(worker)
          worker_group.registry.deregister(worker_group.name, worker.pid)
        end

        def register(worker)
          @workers << worker
          options = worker_group.manager.delay ? { delay: worker_group.manager.delay } : {}
          worker_group.registry.register(worker_group.name, worker.pid, options)
        end

        def current_workers
          worker_group.registry.current(worker_group.name, :worker_count).to_i
        end

        def worker_processes
          worker_group.registry.list(worker_group.name, :worker_list) || []
        end

        def last_spawned
          worker_group.registry.current(worker_group.name, :last_spawned)
        end

        def spawn_blocked?
          worker_group.registry.current(worker_group.name, :spawn_blocked) == '1'
        end

        def able_to_spawn?
          !spawn_blocked?
        end

        private

        def despawn_if_necessary
          despawn! if worker_group.wants_to_remove_workers?
        end

        def despawn!
          worker_to_fire = @workers.pop
          worker_to_fire.stop!
          deregister(worker_to_fire)
        end

        def spawn_if_necessary
          spawn! and return unless min_workers_spawned?
          spawn! if worker_group.wants_to_add_workers? && room_for_more?
        end

        def defaults
          {
            first_at:    1,
            global_max:  0,
            max:         5,
            min:         1
          }
        end

        def min_workers_spawned?
          worker_processes >= min
        end

        def spawn!
          worker = Resque::Plugins::Resqued::Worker.new(worker_options)
          worker.start!
          register(worker) if worker.alive?
        end

        def worker_options
          worker_group.worker_options.merge({ pool: self })
        end

        def room_for_more?
          worker_processes < max
        end
      end
    end
  end
end


