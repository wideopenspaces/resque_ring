module Resque
  module Plugins
    module ResqueRing
      module Registry
        HOST = `hostname`.strip.freeze

        # @return [String] the local machine's hostname
        def host; HOST; end

        # Adds the host to the given value to namespace it
        # by server
        # @param value [String,Integer] the value to be localized
        # @return [String] the given value, with {#host} prepended
        def localize(value)
          "#{host}:#{value}"
        end
      end
    end
  end
end