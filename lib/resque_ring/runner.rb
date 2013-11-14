require 'thor'
require 'resque_ring'
require 'pry'

module SignalHandler
  def intercept(*args)
    handler_opts = args.pop
    args.each do |sig|
      signal = sig.to_s.upcase
      begin
        trap(signal) {
          puts self.inspect
          send handler_opts[:with], signal
        }
      rescue ArgumentError
        warn "Signal (#{signal}) is not supported. Sorry, ol' chap."
      end
    end
  end

  # example:
  #   interceptors :hup => :reload!, :usr1 => :downsize!
  def intercepts(signals)
    signals.each do |signal, interceptor|
      intercept(signal, with: interceptor)
    end
  end
end

module ResqueRing
  class Runner < Thor
    include Thor::Actions
    extend SignalHandler

    intercept :int, :term, :quit, :with => :retire!
    intercepts :hup => :reload!, :usr1 => :downsize!,
      :usr2 => :pause, :cont => :unpause

    map '-v' => :version
    map '-i' => :install
    map '-r' => :start

    desc 'start', 'start a resque_ring'
    method_option :config,
      :required   => true,
      :type       => :string,
      :aliases    => '-c'
    method_option :logfile,
      :type       => :string,
      :aliases    => '-l',
      :default    => './resque_ring.log'
    def start
      @@manager = ResqueRing::Manager.new(options)
      loop { @@manager.run! }
    end

    desc 'install', 'install a sample config file'
    def install
      location    = ask_with_default('Where do you want to put the config file?', 'resque_ring.yml')
      redis_host  = ask_with_default('On what host is redis running?', 'localhost')
      redis_port  = ask_with_default('On what port is redis running?', 6379)
      delay       = ask_with_default('How many seconds should we wait between runs?', 60)
    end

    desc 'version', 'print version'
    def version
      puts ResqueRing::VERSION
    end

    private

    def ask_with_default(statement, default, *args)
      statement = "#{statement} [#{default}]"
      response = ask(statement, *args)
      response.empty? ? default : response
    end

    def self.retire!(signal = 'kill signal')
      puts "#{signal} received"
      exit
    end

    at_exit { @@manager.retire! }
  end
end
