require 'spec_helper'

describe Resque::Plugins::Resqued::Pool do
  let(:worker_group) { Resque::Plugins::Resqued::WorkerGroup.new({}) }
  let(:options) { Hash.new.merge('worker_group' => worker_group) }
  let(:pool) { Resque::Plugins::Resqued::Pool.new(options) }

  subject { pool }

  it 'stores a reference to its worker_group' do
    subject.worker_group.must_equal worker_group
  end

  describe '#spawn!' do
    before do
      worker = Resque::Plugins::Resqued::Worker.new(pool: pool)

      pool.worker_group.expects(:worker_options).at_least_once.returns({})
      Resque::Plugins::Resqued::Worker.expects(:new).with(pool: pool).returns(worker)
      pool.expects(:register).with(worker).returns(true)
      worker.expects(:alive?).returns(true)
    end

    it 'creates a new worker' do
      pool.send(:spawn!)
    end

    it 'checks to see if the worker is alive' do
      pool.send(:spawn!)
    end

    it 'registers the worker into the pool' do
      pool.send(:spawn!)
    end
  end

  context 'with no provided configuration' do
    it 'defaults to a global_max of 0' do
      subject.global_max.must_equal 0
    end

    it 'defaults to a min size of 1' do
      subject.min.must_equal 1
    end

    it 'defaults to a max size of 5' do
      subject.max.must_equal 5
    end

    it 'defaults to a first_at of 1' do
      subject.first_at.must_equal 1
    end
  end

  context 'with provided configuration' do
    let(:options) { {
      'global_max'  => 15,
      'min'         => 2,
      'max'         => 4,
      'first_at'    => 10
    } }
    subject { Resque::Plugins::Resqued::Pool.new(options) }

    it 'sets proper global_max' do
      subject.global_max.must_equal options['global_max']
    end

    it 'sets proper min size' do
      subject.min.must_equal options['min']
    end

    it 'sets proper max size' do
      subject.max.must_equal options['max']
    end

    it 'sets proper first_at' do
      subject.first_at.must_equal options['first_at']
    end
  end
end