# encoding: utf-8

module Core
  module Ext
    # An extension to [Hash] to easily check the presence of multiple keys
    module Hash
      # Does this hash contain all the given keys?
      # @param [Array] expected_keys these are the keys you're looking for
      # @return [Boolean]
      def keys?(*expected_keys)
        keys.contains?(*expected_keys)
      end
    end
  end
end

Hash.send(:include, Core::Ext::Hash)
