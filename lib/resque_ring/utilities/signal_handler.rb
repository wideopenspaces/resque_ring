module ResqueRing
  module Utilities
    # Methods for simply intercepting OS signals and responding to them with handlers
    module SignalHandler
      # takes a list of signals to intercept with a handler
      # the list should terminate with a Hash with one option, with: handler
      # @param args [Array] a list of signals with the last element a hash containing the handler
      # @example
      #   intercept :int, with: :interrupt_handler
      def intercept(*args)
        handler_opts = args.pop
        args.each do |sig|
          signal = sig.to_s.upcase
          begin
            trap(signal) { send handler_opts[:with], signal }
          rescue ArgumentError
            warn "Signal (#{signal}) is not supported. Sorry, ol' chap."
          end
        end
      end

      # Takes a hash of signal/handler pairs and starts trapping the signals appropriately
      # @param signals [Hash] A hash of signals mapped to their appropriate handlers
      # @example
      #   interceptors :hup => :reload!, :usr1 => :downsize!
      def intercepts(signals)
        signals.each { |sig, responder| intercept sig, with: responder }
      end
    end
  end
end