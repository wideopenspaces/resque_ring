module ResqueRing
  # A managed group of Resque workers
  class Pool
    extend HattrAccessor
    extend Forwardable
    def_delegator :worker_group, :manager

    # @return [WorkerGroup] {WorkerGroup} for this Pool
    attr_reader :worker_group

    # @return [Array] Array of Workers managed by this pool
    attr_reader :workers

    # @!method first_at
    #   @return [Integer] How many items should be in the queue before
    #     spawning the first worker. Defaults to 1
    hattr_reader :options, :first_at

    # @!method global_max
    #   @return [Integer] the maximum number of {Worker}s to run across
    #     all servers. Ignored if set to 0. Defaults to 0
    hattr_reader :options, :global_max

    # @!method max
    #   @return [Integer] the maximum number of {Worker}s to run locally.
    #     Defaults to 5.
    hattr_reader :options, :max

    # @!method min
    #   @return [Integer] the minimum number of Workers to keep alive locally.
    #     Defaults to 1
    hattr_reader :options, :min

    # @param options [Hash] options for this Pool
    def initialize(options)
      @workers = []
      @worker_group = options.delete(:worker_group)
      @options = defaults.merge(options)
    end

    # Spins workers up or down as required
    def manage!
      despawn_if_necessary
      spawn_if_necessary
    end

    # Shut down all workers
    def downsize
      workers.each { |worker| despawn!(worker) }
    end

    # Removes a worker from the {Registry}
    # associated with {#worker_group}
    # @param worker [Worker] the worker to be removed
    def deregister(worker)
      RR.logger.info "removing worker #{worker.pid} from registry..."
      worker_group.registry.deregister(worker_group.name, worker.pid)
      @workers.delete(worker)
    end

    # Adds a worker to the list of {#workers} and
    # then adds it to the {Registry}
    # associated with {#worker_group}
    # @param worker [Worker] the worker to be added
    def register(worker)
      @workers << worker unless @workers.include?(worker)

      options = manager.delay ? { delay: worker_group.wait_time } : {}
      worker_group.registry.register(worker_group.name, worker.pid, options)
    end

    # @return [Integer] number of current workers for this Pool
    #   fetched from the {Registry}
    def current_workers
      worker_group.registry.current(worker_group.name, :worker_count).to_i
    end

    # @return [Array] pids of the current worker processes as
    #   fetched from the {Registry}
    def worker_processes
      worker_group.registry.list(worker_group.name, :worker_list) || []
    end

    # @return [String] a string containing the time the last
    #   {Worker} was spawned
    def last_spawned
      worker_group.registry.current(worker_group.name, :last_spawned)
    end

    # @return [Boolean] true if a key called
    #   'spawn_blocked' returns a value of 1
    #   (meaning it hasn't expired in Redis)
    def spawn_blocked?
      worker_group.registry.current(worker_group.name, :spawn_blocked) == '1'
    end

    # @return [Boolean] true if {#spawn_blocked?}
    #   returns false
    def able_to_spawn?
      !spawn_blocked?
    end

    # @return [Boolean] true if {#worker_processes} spawned
    #   is greater than {#min}
    def min_workers_spawned?
      workers.size >= min
    end

    # @return [Boolean] true if {#worker_processes} spawned
    #    is less than {#max}
    def room_for_more?
      under_local_max? && under_global_max?
    end

    def spawn_first_worker?
      return true if first_at && workers.size.zero? &&
        worker_group.wants_to_hire_first_worker?
      !min_workers_spawned?
    end

    private

    def under_local_max?
      workers.size < max
    end

    def under_global_max?
      return true if global_max == 0
      worker_processes.size < global_max
    end

    def defaults
      {
        first_at:    1,
        global_max:  0,
        max:         5,
        min:         1
      }
    end

    def despawn_if_necessary
      return unless @workers.size > min
      despawn! if worker_group.wants_to_remove_workers?
    end

    def despawn!(worker = nil)
      if worker
        worker.stop!
        deregister(worker)
      end
    end

    def spawn_if_necessary
      spawn_first && return if spawn_first_worker?
      spawn! if worker_group.wants_to_add_workers? && room_for_more?
    end

    def spawn_first
      RR.logger.info 'spawning our initial worker(s)!'
      spawn!
    end

    def spawn!
      worker = ResqueRing::Worker.new(worker_options)
      worker.start!
      register(worker) if worker.alive?
    end

    def worker_options
      worker_group.worker_options.merge(pool: self)
    end
  end
end
