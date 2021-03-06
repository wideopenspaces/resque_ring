require 'spec_helper'
require './spec/support/hash_queue_store'

def qstore(queue_values = {})
  queue_values.each do |queue, value|
    store.queues[queue.to_s] = value
  end
end

def add_queues(*queues)
  qg.instance_variable_set('@queues', queues)
end

def prep_queues(queues = {})
  qstore queues
  add_queues queue_a, queue_b
end

describe ResqueRing::QueueGroup do
  parallelize_me!

  let(:store)   { HashQueueStore.new }
  let(:queue_a) { ResqueRing::Queue.new(name: 'queue_a', store: store) }
  let(:queue_b) { ResqueRing::Queue.new(name: 'queue_b', store: store) }
  let(:qg)      { ResqueRing::QueueGroup.new }

  context 'a new QueueGroup' do
    context 'given a list of queues' do
      subject { ResqueRing::QueueGroup.new(*%w(queue_1 queue_2)) }

      it 'creates and stores the queues' do
        subject.map(&:to_s).must_equal(%w(queue_1 queue_2))
      end

      it 'creates a Queue object for each queue' do
        subject.each { |q| q.must_be_instance_of(ResqueRing::Queue) }
      end
    end
  end

  describe '#names' do
    before { add_queues queue_a, queue_b }
    subject { qg.names }

    it 'returns an array of strings containing the queue names' do
      subject.must_equal %w(queue_a queue_b)
    end
  end

  describe '#size' do
    before { prep_queues queue_a: 1, queue_b: 3 }

    context 'with no arguments' do
      subject { qg.size }

      it 'returns the total size of all the queues' do
        subject.must_equal(4)
      end
    end

    context 'with a string containing a queue name' do
      subject { qg.size('queue_a') }

      it 'returns the size of the appropriate queue' do
        subject.must_equal(1)
      end
    end
  end

  describe '#empty?' do
    before { prep_queues queue_a: 0, queue_b: 0 }
    subject { qg.empty? }

    it 'returns true if all queues are empty' do
      subject.must_equal(true)
    end
  end
end
