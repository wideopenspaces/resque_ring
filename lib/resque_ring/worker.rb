require 'childprocess'

module ResqueRing
  # A managed worker process
  class Worker
    extend Forwardable
    def_delegators :process, :pid, :alive?, :exited?

    # @return [Pool] {Pool} that owns this Worker
    attr_reader :pool

    # @return [Hash] options used to create this Worker instance
    attr_reader :options

    # @return [#build] the process manager for this Worker
    attr_reader :process

    # @param options [Hash] the options for creating this Worker
    # @option options [#build] :process_mgr a ChildProcess-compatible
    #   class to manage the Worker process
    # @option options [Pool] :pool {Pool} that owns this Worker
    # @option options [Array] :spawner an Array of elements used to
    #   build the spawn command (from {WorkerGroup#spawner})
    # @option options [Hash] :env from {WorkerGroup#environment}
    # @option options [String] :cwd from {WorkerGroup#work_dir}
    def initialize(options)
      @process_mgr = options.delete(:process_mgr) || ChildProcess
      @pool = options.delete(:pool)
      @options = options

      build!
    end

    # Instructs a worker to start its process
    def start!
      process.start
    end

    # Instructs a worker to die
    def stop!
      Utilities::Logger.info "stopping worker #{pid}"
      process.stop
    end

    private

    def build!
      @process = @process_mgr.build(*options[:spawner])

      set_working_dir(options[:cwd])
      set_environment(options[:env])
    end

    def reset_env!
      ENV.keys.each { |key| process.environment[key] = nil }
    end

    def set_environment(env)
      return unless env && env.size > 0

      reset_env!
      env.each { |k, v| process.environment[k.upcase] = v } unless env.empty?
    end

    def set_working_dir(cwd)
      process.cwd = cwd if cwd
    end
  end
end
