# Utility class ResqueRing can be configured to use for
# processing a queue full of nonsense
class ResqueEmptier
  extend Resque::Plugins::ResqueRing::ManagedJob

  @queue         = :queue_the_first
  @worker_group  = 'indexing'

  def self.perform(item)
    puts "#{Process.ppid} got #{item}"
    sleep(rand(3))
  end
end
