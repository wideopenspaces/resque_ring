module ResqueRing
  # a local representation of a Resque Queue
  class Queue
    # @return [String] the name of this Queue in Resque
    attr_reader :name

    # @!method to_s
    # @return [String] the name of the queue
    alias_method :to_s, :name

    # @return [Resque] an instance of {Resque}
    attr_reader :store

    # @param options [Hash] the options, including name,
    #  and {Resque} instance for this queue
    def initialize(options = {})
      @name   = options.fetch(:name)
      @store  = options.fetch(:store, Resque)
    end

    # @return [Integer] the size of this queue in Resque
    def size
      store.size(name)
    end

    # @return [Boolean] true if the queue is empty
    # @todo see if we can use Resque's #empty
    def empty?
      size.zero?
    end

    # @return [String] a simple representation of the instance
    def inspect
      "Queue:#{object_id}:#{name}:#{size}"
    end
  end
end
