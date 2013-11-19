module ResqueRing
  module Utilities
    module SignalHandler
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

      # example:
      #   interceptors :hup => :reload!, :usr1 => :downsize!
      def intercepts(signals)
        signals.each { |sig, responder| intercept sig, with: responder }
      end
    end
  end
end