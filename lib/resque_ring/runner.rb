require 'thor'
require 'resque_ring'
require 'pry'

require 'resque_ring/ring'

module ResqueRing
  # The guts of the ResqueRing executable
  class Runner < Thor
    include Thor::Actions

    map '-v' => :version
    map '-i' => :install
    map '-r' => :start

    desc 'start', 'start a resque_ring'
    method_option :config,
                  required: true,
                  type:     :string,
                  aliases:  '-c'
    method_option :logfile,
                  type:       :string,
                  aliases:    '-l',
                  default:    './resque_ring.log'
    def start
      ResqueRing::Ring.new(options)
    end

    desc 'version', 'print version'
    def version
      say ResqueRing::VERSION, :green
    end

    # TODO: Add generator for starter config file
    # desc 'install', 'install a sample config file'
    # def install
    #   location    = ask_with_default(
    #     'Where do you want to put the config file?', 'resque_ring.yml')
    #   redis_host  = ask_with_default(
    #     'On what host is redis running?', 'localhost')
    #   redis_port  = ask_with_default('On what port is redis running?', 6379)
    #   delay       = ask_with_default(
    #     'How many seconds should we wait between runs?', 60)
    # end

    ## HELPER METHODS

    no_commands do
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
    end
  end
end
