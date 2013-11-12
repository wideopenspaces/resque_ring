module Resque
  module Plugins
    module ResqueRing
      class Queue
        # @return [String] the name of this Queue in Resque
        attr_reader :name

        # @!method to_s
        # @return [String] the name of the queue
        alias :to_s :name

        # @return [WorkerGroup] the {WorkerGroup} that owns this Queue
        attr_reader :worker_group

        # @return [Resque] an instance of {Resque}
        attr_reader :store

        # @param options [Hash] the options, including name,
        #  parent {WorkerGroup} and {Resque} instance
        #  for this queue
        def initialize(options = {})
          @name = options.delete(:name)
          @worker_group = options.delete(:worker_group)
          @store = options.delete(:store)
        end

        # @return [Integer] the size of this queue in Resque
        def size
          store.size(name) rescue 0
        end

        # @return [String] a simple representation of the instance
        def inspect
          "Queue:#{object_id}:#{name}:#{size}"
        end
      end
    end
  end
end