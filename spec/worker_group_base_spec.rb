require 'spec_helper'

describe Resque::Plugins::Resqued::WorkerGroup do
  let(:mgr) { Resque::Plugins::Resqued::Manager.new({}) }
  let(:options) { Hash.new.merge(manager: mgr) }
  subject { Resque::Plugins::Resqued::WorkerGroup.new('indexing', options) }

  it 'stores a reference to its manager' do
    subject.manager.must_equal mgr
  end

  context 'queues' do
    it 'can get the number of jobs in a single queue'
    it 'can get the total jobs in all watched queues'
  end

  context 'with no provided configuration' do
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
    let(:options) { file = Yambol.load_file('./spec/support/config_with_delay.yml')[:workers][:indexing] }
    let(:wg) { Resque::Plugins::Resqued::WorkerGroup.new('indexing', options) }
    subject { wg }

    it 'knows its spawn command' do
      subject.spawn_command.must_equal options[:spawner][:command]
    end

    it 'knows its work dir' do
      subject.work_dir.must_equal options[:spawner][:dir]
    end

    it 'knows its environment variables' do
      subject.environment.must_equal options[:spawner][:env]
    end

    it 'sets proper wait_time' do
      subject.wait_time.must_equal options[:wait_time]
    end

    it 'sets proper queue threshold' do
      subject.threshold.must_equal options[:threshold]
    end

    it 'sets proper spawn_rate' do
      subject.spawn_rate.must_equal options[:spawn_rate]
    end

    it 'has three watched queues' do
      subject.queues.size.must_equal options[:queues].size
    end

    it 'includes the proper queues' do
      subject.queues.must_equal options[:queues]
    end

    it 'creates a Pool' do
      subject.pool.must_be_instance_of Resque::Plugins::Resqued::Pool
    end

    context 'when #manage! is called' do
      let(:pool) { MiniTest::Mock.new }

      before do
        wg.instance_variable_set(:@pool, pool)
        pool.expect(:manage!, true)
      end

      it 'tells its pool to manage itself' do
        wg.manage!
      end

      after { pool.verify }
    end

    context '#worker_options' do
      subject { wg.worker_options }

      it 'includes the proper keys' do
        subject.keys.must_equal [:spawner, :env, :cwd]
      end

      it 'includes a spawner' do
        subject[:spawner].must_equal wg.spawner
      end

      it 'includes env' do
        subject[:env].must_equal wg.environment
      end

      it 'includes cwd' do
        subject[:cwd].must_equal wg.work_dir
      end
    end

    context '#spawner' do
      context 'if command includes {{queues}}' do
        it 'returns spawn command with queues inserted' do
          subject.spawner.must_equal options[:spawner][:command].each { |c| c.gsub!("{{queues}}", "QUEUES=#{subject.queues.join(',')}") }
        end
      end
    end
  end
end

