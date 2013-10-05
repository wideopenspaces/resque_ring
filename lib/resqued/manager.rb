require 'yaml'

module Resque
  module Plugins
    module Resqued
    	class Manager
    		attr_reader :options, :delay, :worker_groups

    		def initialize(options = {})
    			@options = options
    			config = load_config_file(options[:config]) if options[:config]
    		end

    		def run!
    		end

    		private

    		def load_config_file(config)
    			@config_file ||= ::YAML.load_file(config)
    			if @config_file
    				set_delay(@config_file['delay'])
    				set_worker_groups(@config_file['workers'])
    			end
    		end

    		def set_delay(delay)
    			@delay = delay
    		end

    		def set_worker_groups(worker_groups)
    			@worker_groups = worker_groups
    		end
    	end
    end
  end
end