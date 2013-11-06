require 'spec_helper'
require './spec/support/hash_queue_store'

describe Resque::Plugins::Resqued::Queue do
  let(:mgr) { Resque::Plugins::Resqued::Manager.new({}) }
  let(:options) { Hash.new.merge(manager: mgr) }
  let(:wg) { Resque::Plugins::Resqued::WorkerGroup.new('indexing', options) }
  let(:store) { HashQueueStore.new }
  subject { Resque::Plugins::Resqued::Queue.new(name: 'test', worker_group: wg, store: store) }

  it 'knows its name' do
    subject.name.must_equal('test')
  end

  it 'knows its worker_group' do
    subject.worker_group.must_equal(wg)
  end

  context 'with an empty queue' do
    it 'returns its size as 0' do
      subject.size.must_equal(0)
    end
  end

  context 'with a non-empty queue' do
    before do
      store.queues['test'] = 3
    end

    it 'returns its size appropriately' do
      subject.size.must_equal(3)
    end
  end
end