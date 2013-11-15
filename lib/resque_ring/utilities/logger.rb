require 'yell'
module ResqueRing
  module Utilities
    class Logger
      extend Forwardable
      def_delegators :@@logger, :debug, :info, :warn, :error, :fatal

      DEFAULT_LOGFILE = 'resque_ring.log'

      def initialize(logfile = nil)
        @@logger = Yell.new do |l|
          l.adapter :file, with_default(logfile), level: [:debug, :info, :warn]
          l.adapter STDERR, level: [:error, :fatal]
        end
      end

      def with_default(logfile = nil)
        logfile ||= DEFAULT_LOGFILE
      end
    end
  end
end