# encoding: utf-8

module ResqueRing
  # Methods common to any Registry implementation.
  # Currently only in use by {RedisRegistry}
  module Registry
    HOST = `hostname`.strip.freeze

    # @return [String] the local machine's hostname
    def host
      HOST
    end

    # Adds the host to the given value to namespace it
    # by server
    # @param value [String,Integer] the value to be localized
    # @return [String] the given value, with {#host} prepended
    def localize(value)
      "#{host}:#{value}"
    end
  end
end
