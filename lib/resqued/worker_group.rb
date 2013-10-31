module Resque
  module Plugins
    module Resqued
      class WorkerGroup
        extend HattrReader

        attr_reader :name, :manager
        hattr_reader :options, 'queues', 'spawn_rate', 'threshold', 'wait_time'

        def initialize(name, options = {})
          @name = name
          @manager = options.delete('manager')
          @options = defaults.merge(options)
        end

        def environment
          @env ||= @options['spawner']['env']
        end

        def manage!
          pool.manage!
        end

        def spawn_command
          @spawn_command ||= @options['spawner']['command']
        end

        def spawner
          spawn_command.collect { |c| c.gsub('{{queues}}', "QUEUES=#{queues.join(',')}") }
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

        private

        def defaults
          {
            'queues'      => [],
            'spawn_rate'  => 1,
            'threshold'   => 100,
            'wait_time'   => 60
          }
        end
      end
    end
  end
end