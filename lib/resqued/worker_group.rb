module Resque
  module Plugins
    module Resqued
      class WorkerGroup
        attr_reader :name, :manager

        def initialize(name, options = {})
          @name = name
          @manager = options.delete('manager')
          @options = options
        end

        def environment
          @env ||= @options['spawner']['env']
        end

        def manage!
          pool.manage!
        end

        def queues
          @options['queues'] || []
        end

        def spawn_rate
          @options['spawn_rate'] || 1
        end

        def spawn_command
          @spawn_command ||= @options['spawner']['command']
        end

        def spawner
          spawn_command.collect { |c| c.gsub('{{queues}}', "QUEUES=#{queues.join(',')}") }
        end

        def threshold
          @options['threshold'] || 100
        end

        def wait_time
          @options['wait_time'] || 60
        end

        def work_dir
          @work_dir ||= @options['spawner']['dir']
        end

        def worker_options
          { spawner: spawner, env: environment, cwd: work_dir }
        end

        def pool
          @options['pool'] ||= {}
          @pool ||= Resque::Plugins::Resqued::Pool.new(@options['pool'].merge('worker_group' => self))
        end
      end
    end
  end
end