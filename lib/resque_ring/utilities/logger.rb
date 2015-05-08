# encoding: utf-8

require 'yell'
module ResqueRing
  module Utilities
    # A ResqueRing logger, implemented with Yell
    class Logger
      include Singleton
      extend Forwardable
      def_delegators :@logger, :debug, :info, :warn, :error, :fatal

      DEFAULT_LOGFILE = 'resque_ring.log'
      @logger         = nil

      class << self
        def logfile(logfile = nil)
          new(logfile)
        end

        def method_missing(method_id, *args, &block)
          if instance.respond_to?(method_id)
            instance.send(method_id, *args, &block)
          else
            super
          end
        end
      end

      def initialize(logfile = nil)
        @logger = Yell.new do |l|
          l.adapter :file, with_default(logfile), level: [:debug, :info, :warn]
          l.adapter STDERR, level: [:error, :fatal]
        end
      end

      def with_default(logfile = nil)
        logfile || DEFAULT_LOGFILE
      end
    end
  end
end
