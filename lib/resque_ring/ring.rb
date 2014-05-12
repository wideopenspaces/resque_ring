# encoding: utf-8

require 'resque_ring/utilities/signal_handler'
require 'benchmark'

module ResqueRing
  # Container for an entire manager/worker group/pool/worker organization
  class Ring
    include Globals
    extend ResqueRing::Utilities::SignalHandler

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

    attr_accessor :options, :manager, :retired

    def initialize(options)
      @options = options
    end

    def run
      hire_manager(options) unless manager

      manager.run!
      productive_sleep(manager.delay) { handle_signals }

      run_unless_retired
    end

    # SUPPORTING CAST

    # Allows [Manager] to run and respawn
    def continue!(_signal = nil)
      manager.continue!
    end

    # Fires all workers but leaves the main loop running.
    def downsize!(_signal = nil)
      manager.downsize!
    end

    # Instructs the manager to downsize and then gets rid of him
    # @return [Nil]
    def fire_manager
      manager.downsize!
      @manager = nil
    end

    # Creates a new instance of [Manager].
    # @return [ResqueRing::Manager]
    def hire_manager(options)
      options ||= @options
      fail StandardError unless options

      @manager = ResqueRing::Manager.new(options)
    end

    # Fires current workers and prevents [Manager]
    # from running
    def pause!(_signal = nil)
      manager.pause!
      manager.downsize!
    end

    # Fires all workers and starts all over again
    # with a new manager. This reloads the configuration
    # file.
    def reload!(_signal = nil)
      fire_manager
    end

    # Fires all workers and shuts down.
    def retire!(_signal = nil)
      @retired = true
      fire_manager
    end

    # A more productive, if imprecise, sleep.
    # Attempts to adjust for time spent in the block.
    #
    # @param [Number] delay the amount of time in seconds to elapse
    # @yield something to do while lucid dreaming...
    def productive_sleep(delay)
      1.upto(delay) do
        elapsed = Benchmark.realtime { yield }
        sleep(1 - [elapsed, 1].min)
      end
    end

    private

    alias_method :retired?, :retired

    def run_unless_retired
      run unless retired?
    end

    # Monitors the signal queue for new events and
    #   runs the appropriate method when a new event is
    #   detected
    def handle_signals
      while (sig = Globals.signals.shift)
        logger.debug "Got signal: #{sig}"
        send(SIG_ACTS[sig], '') if SIG_ACTS.keys?(sig)
      end
    end

    class << self
      def catch_signal(signal)
        Globals.signals << signal
      end
    end
  end
end
