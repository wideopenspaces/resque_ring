require 'thor'
require 'redis'
require_relative '../lib/resque_ring'

$redis = Redis.new

class RedisFiller
  def self.fill(queue, number_entries = 100)
    number_entries.times do |i|
      $redis.rpush queue, i
    end
  end
end

class RedisEmptier
  def self.pop
    $redis.lpop($queue)
  end

  def self.full?
    $redis.llen($queue) > 0
  end

  def self.empty!
    loop do
      puts "#{Process.pid} got #{self.pop}" if self.full?
      sleep(rand(3))
    end
  end
end

class RRTester < Thor
  include Thor::Actions

  desc 'fill', 'fill the queue'
  method_option :config,
    required:   true,
    type:       :string,
    aliases:    '-c'
  def fill
    get_size
    get_queue
    start_server?

    fill_queue if @size
    start_server if @manage
  end

  desc 'empty', 'start a simple client'
  method_option :queue,
    required:   true,
    type:       :string,
    aliases:    '-q'
  def empty
    $queue = options[:queue]
    RedisEmptier.empty!
  end

  private
  def get_size
    @size = ask('How many queue items would you like to add?')
  end

  def get_queue
    @queue  = ask('What is the name of your queue?')
    @queue  = "resque:queue:#{@queue}"
  end

  def fill_queue
    say "Maximizing widget pipeline...", :yellow
    RedisFiller.fill(@queue, @size.to_i)
  end

  def start_server
    say "Initiating imminent actualization...", :green
    ResqueRing::Runner.start(['start'] + ARGV[1..-1])
  end

  def start_server?
    @manage = yes?('Start the manager?', :red)
  end

end

RRTester.start(ARGV)
