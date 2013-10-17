require 'childprocess'

module Resque
  module Plugins
    module Resqued
      class Worker
        attr_reader :pool, :options, :process

        def initialize(options)
          @process_mgr = options.delete(:process_mgr) || ChildProcess
          @pool = options.delete(:pool)
          @options = options

          build!
        end

        def start!
          process.start
        end

        def stop!
          process.stop
        end

        # allow the worker to pretend it is a Process object
        def method_missing(method, *args, &block)
          process.send(method, *args, &block)
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
          env.each { |k,v| process.environment[k.upcase] = v } unless env.empty?
        end

        def set_working_dir(cwd)
          process.cwd = cwd if cwd
        end
      end
    end
  end
end