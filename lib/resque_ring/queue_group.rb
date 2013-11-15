module ResqueRing
  class QueueGroup
    attr_reader :queues

    def initialize(*queues)
      @queues ||= {}
      prepare(queues)
    end

    # @return [Integer] the number of watched queues
    def count
      @queues.size
    end

    # param queue [String] name of queue to be checked (optional)
    # @return [Boolean] true if size of queue(s) equals 0
    def empty?(queue = nil)
      size(queue) == 0
    end

    # param queue [String] name of queue to be checked (optional)
    # @return [Integer] sum of sizes of all associated queues,
    #   or named queue if given
    def size(queue = nil)
      return queues.fetch(queue, []).size if queue
      queues.values.map(&:size).reduce(:+) || 0
    end

    # @return [Array] a list of names of the watched queues
    def names
      queues.each_value.map(&:to_s)
    end

    private

    # @todo check for wildcard queue names and
    #   fetch names of all matching queues in redis
    #   before loading up the list of queues
    def prepare(queues)
      queues.each do |q|
        @queues.store(q, Queue.new(name: q, worker_group: self, store: Resque))
      end
    end
  end
end