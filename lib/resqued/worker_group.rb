module Resque
  module Plugins
    module Resqued
      class WorkerGroup
        extend HattrAccessor

        attr_reader :name, :manager, :queues
        hattr_reader :options, :spawn_rate, :threshold, :wait_time, :remove_when_idle

        def initialize(name, options = {})
          @name = name.to_s
          @manager = options.delete(:manager)

          build_queues(options.fetch(:queues, nil))
          @options = defaults.merge(options)
        end

        def environment
          @env ||= @options[:spawner][:env]
        end

        def manage!
          pool.manage!
        end

        def spawn_command
          @spawn_command ||= @options[:spawner][:command]
        end

        def spawner
          spawn_command.collect { |c| c.gsub('{{queues}}', "QUEUES=#{queues.map(&:to_s).join(',')}") }
        end

        def wants_to_add_workers?
          queues_total >= threshold && pool.ready_to_spawn
        end

        def wants_to_remove_workers?
          remove_when_idle && queues_are_empty?
        end

        def work_dir
          @work_dir ||= @options[:spawner][:dir]
        end

        def worker_options
          { spawner: spawner, env: environment, cwd: work_dir }
        end

        def pool
          @pool ||= Resque::Plugins::Resqued::Pool.new(@options[:pool].merge(worker_group: self))
        end

        def queues_total
          queues.values.map(&:size).reduce(:+)
        end

        def queues_are_empty?
          queues_total == 0
        end

        def registry
          manager.registry
        end

        private

        def build_queues(queues)
          @queues ||= {}

          return if queues.nil?
          queues.each do |q|
            @queues.store(q, Queue.new(name: q, worker_group: self))
          end
        end

        def defaults
          {
            spawn_rate:       1,
            threshold:        100,
            wait_time:        60,
            remove_when_idle: false,
            pool:             {}
          }
        end
      end
    end
  end
end