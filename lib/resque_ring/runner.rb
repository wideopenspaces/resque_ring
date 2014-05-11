# encoding: utf-8

require 'thor'
require 'resque_ring'
require 'pry'

require 'resque_ring/ring'
require 'resque_ring/pid_file'

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
    method_option :pidfile,
                  type:       :string,
                  aliases:    '-p',
                  default:    './resque_ring.pid'
    def start
      PidFile.write options[:pidfile]
      ResqueRing::Ring.new(options)
    end

    desc 'stop', 'stop a running instance'
    method_option :pidfile,
                  type:     :string,
                  aliases:  '-p',
                  default:  './resque_ring.pid'
    def stop
      signal! 'INT', options[:pidfile]
    end

    desc 'reload', 'reload a running instance'
    method_option :pidfile,
                  type:     :string,
                  aliases:  '-p',
                  default:  './resque_ring.pid'
    def reload
      signal! 'HUP', options[:pidfile]
    end

    desc 'downsize', 'quit all existing workers'
    method_option :pidfile,
                  type:     :string,
                  aliases:  '-p',
                  default:  './resque_ring.pid'
    def downsize
      signal! 'USR1', options[:pidfile]
    end

    desc 'pause', 'pause a running instance'
    method_option :pidfile,
                  type:     :string,
                  aliases:  '-p',
                  default:  './resque_ring.pid'
    def pause
      signal! 'USR2', options[:pidfile]
    end

    desc 'continue', 'un-pause a running instance'
    method_option :pidfile,
                  type:     :string,
                  aliases:  '-p',
                  default:  './resque_ring.pid'
    def continue
      signal! 'CONT', options[:pidfile]
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

      def signal!(signal, pidfile)
        PidFile.with_existing_pid(pidfile) { |pid| Process.kill(signal, pid) }
      end
    end
  end
end
