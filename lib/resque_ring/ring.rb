require 'resque_ring/utilities/signal_handler'

module ResqueRing
  class Ring
    extend ResqueRing::Utilities::SignalHandler
    # include ResqueRing::Process::Signals
    # include ResqueRing::Process::Workflow

    $signals = []
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
    def continue!(signal = 'continue signal')
      @manager.continue!
    end

    # Fires all workers but leaves the main loop running.
    def downsize!(signal = 'downsize')
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
      while sig = $signals.shift
        Utilities::Logger.debug "Got signal: #{sig}"
        self.send(SIG_ACTS[sig]) if SIG_ACTS.keys?(sig)
      end
    end

    # Creates a new instance of [Manager].
    # @return [ResqueRing::Manager]
    def hire_manager(options)
      @options ||= options
      raise StandardError unless defined?(@options)

      @manager = ResqueRing::Manager.new(@options)
    end

    # Fires current workers and prevents [Manager]
    # from running
    def pause!(signal = 'pause signal')
      @manager.pause!
      @manager.downsize!
    end

    # Fires all workers and starts all over again
    # with a new manager. This reloads the configuration
    # file.
    def reload!(signal = 'reload')
      fire_manager
    end

    # Fires all workers and shuts down.
    def retire!(signal = 'retire')
      fire_manager; exit
    end

    # A more productive, if imprecise, sleep.
    # @param [Number] delay the amount of time in seconds to elapse
    # @yield something to do while lucid dreaming...
    def productive_sleep(delay)
      0.upto(delay) { yield; sleep 1 }
    end

    class << self
      def catch_signal(signal)
        puts "Caught signal #{signal}"
        $signals << signal
      end
    end
  end
end
