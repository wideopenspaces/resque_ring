require 'resque_ring/utilities/signal_handler'

module ResqueRing
  module Process
    module Signals
      $signals = []

      def self.included(base)
        base.extend ClassMethods
        base.extend ResqueRing::Utilities::SignalHandler

        base.intercept :int, :term, :quit, :hup, :usr1, :usr2, :cont,
          with: :catch_signal
      end

      def handle_signals(&block)
        while sig = $signals.shift
          Utilities::Logger.debug "Got signal: #{sig}"
          if block_given?
            yield(sig)
          else
            puts "No block defined. Using defaults"
            Process.kill($$, sig)
          end
        end
      end

      module ClassMethods
        def catch_signal(signal)
          puts "Caught signal #{signal}"
          $signals << signal
        end
      end
    end
  end
end
