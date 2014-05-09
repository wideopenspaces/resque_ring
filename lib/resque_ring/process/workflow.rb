module ResqueRing
  module Process
    module Workflow
      QUIT = ->{ downsize! and exit }
      SIG_ACTS = {
        'INT'   => QUIT,
        'TERM'  => QUIT,
        'QUIT'  => QUIT,
        'HUP'   => ->{ reload!   },
        'USR1'  => ->{ downsize! },
        'USR2'  => ->{ pause!    },
        'CONT'  => ->{ continue! }
      }

      def self.included(base)
        # base.extend ClassMethods
      end

      def do_work
        binding.pry
        $manager.run!
        while_waiting($manager.delay) { handle_signals }
      end

      def handle_signals
        puts "handling signal in Workflow!" unless $signals.empty?
        binding.pry
        handler = ->(sig) { SIG_ACTS[sig].call if SIG_ACTS[sig] }
        super(&handler)
      end

      def hire(options)
        self.class.hire_manager(options)
      end

      def while_waiting(delay)
        0.upto(delay) { yield; sleep 1 }
      end

        def hire_manager(options)
          @options ||= options
          raise StandardError unless defined?(@options)

          $manager = ResqueRing::Manager.new(@options)
        end

        def fire_manager
          $manager.downsize!
          $manager = nil
        end

        # Fires all workers and starts all over again
        # with a new manager. This reloads the configuration
        # file.
        def reload!(signal = 'reload')
          fire_manager and hire_manager(@options)
        end

        # Fires all workers but leaves the main loop running.
        def downsize!(signal = 'downsize')
          $manager.downsize!
        end

        # Fires current workers and prevents [Manager]
        # from running
        def pause!(signal = 'pause signal')
          $manager.pause!
          $manager.downsize!
        end

        # Allows [Manager] to run and respawn
        def continue!(signal = 'continue signal')
          $manager.continue!
        end

        # Fires all workers and shuts down.
        def retire!(signal = 'retire')
          fire_manager and exit
        end
      # module ClassMethods

      # end
    end
  end
end
