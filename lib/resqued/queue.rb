module Resque
  module Plugins
    module Resqued
      class Queue
        attr_reader :name, :worker_group, :store

        def initialize(options = {})
          @name = options.delete(:name)
          @worker_group = options.delete(:worker_group)
          @store = options.delete(:store)
        end

        def size
          store.size(name) rescue 0
        end

        def to_s
          name
        end
      end
    end
  end
end