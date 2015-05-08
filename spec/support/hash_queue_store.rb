# A lightweight Redis stand-in for testing purposes
class HashQueueStore
  attr_reader :queues

  def initialize
    @queues = Hash.new(0)
  end

  def size(key)
    @queues[key]
  end
end
