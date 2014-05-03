require 'thor'
require 'resque_ring'
require 'pry'

require 'resque_ring/utilities/signal_handler'

module ResqueRing
  # The guts of the ResqueRing executable
  class Runner < Thor
    include Thor::Actions
    extend ResqueRing::Utilities::SignalHandler

    intercept :int, :term, :quit, with: :retire!
    intercepts hup: :reload!, usr1: :downsize!
      # usr2: :pause
      # cont: :unpause

    map '-v' => :version
    map '-i' => :install
    map '-r' => :start

    desc 'start', 'start a resque_ring'
    method_option :config,
      required:   true,
      type:       :string,
      aliases:    '-c'
    method_option :logfile,
      type:       :string,
      aliases:    '-l',
      default:    './resque_ring.log'
    def start
      @@retired = false
      @@manager = ResqueRing::Manager.new(options)
      @@options ||= options

      at_exit { @@manager.retire!  }
      until retired? do
        @@manager.run!
      end
    end

    # desc 'install', 'install a sample config file'
    # def install
    #   location    = ask_with_default('Where do you want to put the config file?', 'resque_ring.yml')
    #   redis_host  = ask_with_default('On what host is redis running?', 'localhost')
    #   redis_port  = ask_with_default('On what port is redis running?', 6379)
    #   delay       = ask_with_default('How many seconds should we wait between runs?', 60)
    # end

    desc 'version', 'print version'
    def version
      say ResqueRing::VERSION, :green
    end

    private

    # Asks for a response with a default value
    # if the response is empty
    # @param statement [String] the question to be asked
    # @param default [Object] the default value
    # return [Object] the response or the default value
    def ask_with_default(statement, default, *args)
      statement  = "#{statement} [#{default}]"
      response   = ask(statement, *args)
      response.empty? ? default : response
    end

    # Have we been told to retire?
    # @return [Boolean] true or false
    def retired?
      defined?(@@retired) && @@retired == true
    end

    # Fires all workers and starts all over again
    # with a new manager. This reloads the configuration
    # file.
    def self.reload!(signal = 'reload')
      @@manager.retire! && start if defined?(@@manager)
    end

    # def self.pause!(signal = 'pause signal')
    #   @@manager.furlough! if defined?(@@manager)
    # end
    #
    # def self.continue!(signal = 'continue signal')
    #   @@manager.continue! if defined?(@@manager)
    # end

    # Fires all workers and shuts down.
    def self.retire!(signal = 'retire')
      @@retired = true; exit
    end
  end
end
