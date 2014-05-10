module Core
  module Ext
    # An extension to Array to check for presence of multiple values
    module Array
      # Does this array contain all the given values?
      # @param [Array] values these are the values you're looking for
      # @return [Boolean]
      def contains?(*values)
        values.all? { |value| include?(value) }
      end
    end
  end
end

Array.send(:include, Core::Ext::Array)
