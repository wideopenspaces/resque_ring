require 'thor'
require 'resque'
require_relative '../lib/resque_ring'
require_relative '../lib/resque/plugins/resque_ring/managed_job'

$redis = Redis.new

Resque.redis = 'localhost:6379'

module Resque
  def self.enqueue(*args)
    super(*args)
  end
end

class ResqueEmptier
  extend Resque::Plugins::ResqueRing::ManagedJob

  @queue         = :queue_the_first
  @worker_group  = 'indexing'

  def self.perform(item)
    puts "#{Process.pid} got #{item}"
    sleep(rand(3))
  end
end

class ResqueFiller
  def self.fill(number_entries = 100)
    number_entries.times do |i|
      Resque::enqueue(RedisEmptier, i)
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
    queue = options[:queue]
    Resque::Worker.new(queue).work
  end

  private
  def get_size
    @size = ask('How many queue items would you like to add?')
  end

  def fill_queue
    say "Maximizing widget pipeline...", :yellow
    ResqueFiller.fill(@size.to_i)
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
