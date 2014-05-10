require 'resque_ring/utilities/signal_handler'
require 'benchmark'

module ResqueRing
  # Container for an entire manager/worker group/pool/worker organization
  class Ring
    extend ResqueRing::Utilities::SignalHandler
    # include ResqueRing::Process::Signals
    # include ResqueRing::Process::Workflow

    QUIT     = :retire!
    SIG_ACTS = {
      'INT'   => :retire!,
      'TERM'  => :retire!,
      'QUIT'  => :retire!,
      'HUP'   => :reload!,
      'USR1'  => :downsize!,
      'USR2'  => :pause!,
      'CONT'  => :continue!
    }

    intercept :int, :term, :quit, :hup, :usr1, :usr2, :cont,
              with: :catch_signal

    attr_reader :options

    def initialize(options)
      @options = options

      run
    end

    def run
      hire_manager(options) unless @manager

      @manager.run!
      productive_sleep(@manager.delay) { handle_signals }

      run
    end

    # SUPPORTING CAST

    # Allows [Manager] to run and respawn
    def continue!(_signal)
      @manager.continue!
    end

    # Fires all workers but leaves the main loop running.
    def downsize!(_signal)
      @manager.downsize!
    end

    # Instructs the manager to downsize and then gets rid of him
    # @return [Nil]
    def fire_manager
      @manager.downsize!
      @manager = nil
    end

    # Monitors the signal queue for new events and
    #   runs the appropriate method when a new event is
    #   detected
    def handle_signals
      while (sig = ResqueRing.signals.shift)
        RR.logger.debug "Got signal: #{sig}"
        send(SIG_ACTS[sig]) if SIG_ACTS.keys?(sig)
      end
    end

    # Creates a new instance of [Manager].
    # @return [ResqueRing::Manager]
    def hire_manager(options)
      @options ||= options
      fail StandardError unless defined?(@options)

      @manager = ResqueRing::Manager.new(@options)
    end

    # Fires current workers and prevents [Manager]
    # from running
    def pause!(_signal)
      @manager.pause!
      @manager.downsize!
    end

    # Fires all workers and starts all over again
    # with a new manager. This reloads the configuration
    # file.
    def reload!(_signal)
      fire_manager
    end

    # Fires all workers and shuts down.
    def retire!(_signal)
      fire_manager
      exit
    end

    # A more productive, if imprecise, sleep.
    # Attempts to adjust for time spent in the block.
    #
    # @param [Number] delay the amount of time in seconds to elapse
    # @yield something to do while lucid dreaming...
    def productive_sleep(delay)
      0.upto(delay) do
        elapsed = Benchmark.realtime { yield }
        sleep(1 - [elapsed, 1].min)
      end
    end

    class << self
      def catch_signal(signal)
        puts "Caught signal #{signal}"
        ResqueRing.signals << signal
      end
    end
  end
end
