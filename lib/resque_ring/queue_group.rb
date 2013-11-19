module ResqueRing
  class QueueGroup
    include Enumerable
    attr_reader :queues

    def initialize(*queues)
      @queues = []
      prepare(queues)
    end

    # @return [Integer] the number of watched queues
    def count
      @queues.size
    end

    # Turn this class into an Enumerator, yielding
    # the contents of @queues
    def each(&block)
      @queues.each(&block)
    end

    # param name [String] name of queue to be checked (optional)
    # @return [Boolean] true if size of queue(s) equals 0
    def empty?(name = '.+')
      queues_matching(name).all?(&:empty?)
    end

    # @return [Array] a list of names of the watched queues
    def names
      map(&:name)
    end

    # param name [String] name of queue to be checked (optional)
    # @return [Integer] sum of sizes of all associated queues,
    #   or named queue if given
    def size(name = '.+')
      queues_matching(name).map(&:size).reduce(0, :+)
    end

    private

    def queues_matching(name)
      select { |queue| queue.name.match /\A#{name}\z/ }
    end

    # @todo check for wildcard queue names and
    #   fetch names of all matching queues in redis
    #   before loading up the list of queues
    def prepare(queues)
      @queues = queues.collect { |q| Queue.new(name: q, store: Resque) }
    end
  end
end