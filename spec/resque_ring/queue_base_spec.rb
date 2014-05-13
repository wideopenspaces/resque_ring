require 'spec_helper'
require './spec/support/hash_queue_store'

describe ResqueRing::Queue do
  parallelize_me!

  let(:mgr)     { ResqueRing::Manager.new({}) }
  let(:options) { Hash.new.merge(manager: mgr) }
  let(:store)   { HashQueueStore.new }
  subject       { ResqueRing::Queue.new(name: 'test', store: store) }

  it 'knows its name' do
    subject.name.must_equal('test')
  end

  describe '#to_s' do
    it 'returns the name of the queue' do
      subject.to_s.must_equal('test')
    end
  end

  describe '#inspect' do
    it 'returns a simple representation of the object' do
      subject.inspect.must_equal(
        "Queue:#{subject.object_id}:#{subject.name}:#{subject.size}")
    end
  end

  context 'with an empty queue' do
    it 'returns its size as 0' do
      subject.size.must_equal(0)
    end

    describe '#empty?' do
      it 'returns true' do
        subject.empty?.must_equal(true)
      end
    end
  end

  context 'with a non-empty queue' do
    before do
      store.queues['test'] = 3
    end

    it 'returns its size appropriately' do
      subject.size.must_equal(3)
    end

    describe '#empty?' do
      it 'returns false' do
        subject.empty?.must_equal(false)
      end
    end
  end
end
