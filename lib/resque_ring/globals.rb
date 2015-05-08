# encoding: utf-8

module ResqueRing
  # A container for a few frequently accessed 'globals'
  module Globals
    GLOBAL_VARS = [:logger, :signals, :config, :registry]

    @logger   = ResqueRing::Utilities::Logger.logfile(nil)
    @signals  = []
    @config   = nil

    private

    def self.define_globals
      GLOBAL_VARS.each do |global|
        define_setter global
        define_getter global
      end
    end

    def self.define_setter(global)
      define_method :"#{global}=" do |value|
        Globals.send(:instance_variable_set, :"@#{global}", value)
      end
    end

    def self.define_getter(global)
      define_method global do
        Globals.send(:instance_variable_get, :"@#{global}")
      end
    end

    public

    # Creates module-specific accessors for the
    # module instance variables.
    #
    # These are not accessible from the including class
    class << self
      GLOBAL_VARS.each { |global| attr_accessor global }
    end

    # Defines class methods in the including class
    # for getting and setting the global vars stored here
    def self.included(base)
      class << base
        Globals.define_globals
      end
    end

    # Creates instance methods on the including class
    # for getting and setting the global vars stored here.
    #
    # These get included into the including class.
    Globals.define_globals
  end
end
