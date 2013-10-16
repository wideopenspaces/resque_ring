require 'spec_helper'

describe Resque::Plugins::Resqued::WorkerGroup do
  context 'with no provided configuration' do
    let(:options) { Hash.new }
    subject { Resque::Plugins::Resqued::WorkerGroup.new('indexing', options) }

    it 'defaults to a wait_time of 60' do
      subject.wait_time.must_equal 60
    end

    it 'defaults to a queue threshold of 100' do
      subject.threshold.must_equal 100
    end

    it 'defaults to a spawn_rate of 1' do
      subject.spawn_rate.must_equal 1
    end

    it 'defaults to no watched queues' do
      subject.queues.must_equal []
    end

    it 'creates a Pool' do
      subject.pool.class.must_equal Resque::Plugins::Resqued::Pool
    end
  end

  context 'with a provided configuration' do
    let(:options) { {
      'wait_time'   => 120,
      'spawn_rate'  => 2,
      'threshold'   => 10,
      'queues'      => %w(queue1, queue2, queue3) }
    }
    subject { Resque::Plugins::Resqued::WorkerGroup.new('indexing', options) }

    it 'sets a wait_time of 120' do
      subject.wait_time.must_equal options['wait_time']
    end

    it 'sets a queue threshold of 10' do
      subject.threshold.must_equal options['threshold']
    end

    it 'sets a spawn_rate of 2' do
      subject.spawn_rate.must_equal options['spawn_rate']
    end

    it 'has three watched queues' do
      subject.queues.size.must_equal options['queues'].size
    end

    it 'includes the proper queues' do
      subject.queues.must_equal options['queues']
    end

    it 'creates a Pool' do
      subject.pool.class.must_equal Resque::Plugins::Resqued::Pool
    end
  end
end

