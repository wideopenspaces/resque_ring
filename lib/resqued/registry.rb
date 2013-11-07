module Resque
  module Plugins
    module Resqued
      module Registry
        HOST = `hostname`.strip.freeze
        def host; HOST; end

        def localize(value)
          "#{host}:#{value}"
        end
      end
    end
  end
end