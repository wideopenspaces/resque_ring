require 'spec_helper'

describe Resque::Plugins::Resqued::Pool do
  let(:manager) { Resque::Plugins::Resqued::Manager.new }
  let(:worker_group) { Resque::Plugins::Resqued::WorkerGroup.new('test', manager: manager) }
  let(:options) { Hash.new.merge(worker_group: worker_group) }
  let(:pool) { Resque::Plugins::Resqued::Pool.new(options) }

  subject { pool }

  it 'stores a reference to its worker_group' do
    subject.worker_group.must_equal worker_group
  end

  context 'through the registry' do
    let(:worker) { Resque::Plugins::Resqued::Worker.new(pool: pool) }
    let(:fake_pid) { 1001 }
    let(:localized_pid) { "#{manager.registry.host}:1001" }

    it 'can tell how many workers are active' do
      subject.current_workers.must_equal(0)
    end

    it 'can list the pids of the active workers' do
      subject.worker_processes.must_equal([])
    end

    context 'when registering workers' do
      before do
        manager.instance_variable_set(:@delay, 30)
        manager.registry.reset!(worker_group.name)

        worker.expects(:pid).returns(fake_pid)
        subject.register(worker)
      end

      it 'stores the pid' do
        subject.worker_processes.must_include(localized_pid)
      end

      it 'increments the worker count' do
        subject.current_workers.must_equal(1)
      end

      it 'updates last_spawned' do
        subject.last_spawned.wont_be_nil
      end

      it 'blocks the spawner' do
        subject.spawn_blocked?.must_equal(true)
      end

      after { worker.unstub(:pid) }
    end

    context 'when de-registering workers' do
      before do
        manager.registry.reset!(worker_group.name)
        worker.expects(:pid).at_least_once.returns(fake_pid)
        subject.register(worker)
        subject.deregister(worker)
      end

      it 'removes the pid' do
        subject.worker_processes.wont_include(localized_pid)
      end

      it 'decrements the worker count' do
        subject.current_workers.must_equal(0)
      end

      after { worker.unstub(:pid) }
    end
  end

  describe '#manage' do
    subject { pool.manage! }

    context 'when worker_group wants to remove workers' do
      before do
        worker_group.stubs(:wants_to_remove_workers?).returns(true)
        3.times { pool.workers.unshift(Resque::Plugins::Resqued::Worker.new(pool: pool)) }

        @worker_to_fire = pool.workers.last
        @worker_to_fire.process.expects(:stop).returns(true)
        pool.expects(:deregister).with(@worker_to_fire).returns(true)

        pool.stubs(:spawn_if_necessary).returns(true)
      end

      it 'tells the last worker in the list to stop' do
        subject
      end

      it 'deregisters the last worker in the list' do
        subject
      end

      after { pool.unstub }
    end

    context 'when the minimum workers have not been spawned' do
      before do
        pool.expects(:min_workers_spawned?).returns(false)
        worker_group.expects(:worker_options).returns({})

        @worker = Resque::Plugins::Resqued::Worker.new(pool: pool)

        # creates a new worker
        Resque::Plugins::Resqued::Worker.expects(:new).at_least_once.returns(@worker)

        # attempts to start
        @worker.expects(:start).at_least_once.returns(true)

        # registers the new worker
        pool.expects(:register).with(@worker).returns(true)
      end

      it 'creates a new worker' do
        subject
      end

      it 'attempts to start the new worker' do
        subject
      end

      it 'registers the new worker' do
        subject
      end

      after do
        Resque::Plugins::Resqued::Worker.unstub
        @worker.unstub
        pool.unstub
      end
    end

    context 'when there are more than the minimum workers' do
      before { pool.expects(:min_workers_spawned?).returns(true) }

      context 'when worker_group wants to add workers' do
        before { worker_group.expects(:wants_to_add_workers?).returns(true) }

        context 'when there is room for more' do
          before do
            pool.expects(:room_for_more?).returns(true)
            worker_group.expects(:worker_options).returns({})

            @worker = Resque::Plugins::Resqued::Worker.new(pool: pool)

            # creates a new worker
            Resque::Plugins::Resqued::Worker.expects(:new).at_least_once.returns(@worker)

            # attempts to start
            @worker.expects(:start).at_least_once.returns(true)

            # registers the new worker
            pool.expects(:register).with(@worker).returns(true)
          end

          it 'creates a new worker' do
            subject
          end

          it 'attempts to start the new worker' do
            subject
          end

          it 'registers the new worker' do
            subject
          end
        end
      end
    end
  end

  describe '#able_to_spawn' do
    context 'when spawning is not blocked' do
      before { pool.expects(:spawn_blocked?).returns(false) }

      it 'returns true' do
        pool.able_to_spawn?.must_equal(true)
      end
    end

    context 'when spawning is blocked' do
      before { pool.expects(:spawn_blocked?).returns(true) }

      it 'returns false' do
        pool.able_to_spawn?.must_equal(false)
      end
    end
  end

  describe '#min_workers_spawned?' do
    before  { pool.stubs(:min).returns(1) }
    subject { pool.min_workers_spawned? }

    context 'when worker processes are greater than min' do
      before { pool.expects(:worker_processes).returns([1,2,3]) }
      it 'returns true' do
        subject.must_equal(true)
      end
    end

    context 'when worker_processes are the same as min' do
      before { pool.expects(:worker_processes).returns([3]) }
      it 'returns true' do
        subject.must_equal(true)
      end
    end

    context 'when worker_processes are less than min' do
      before { pool.expects(:worker_processes).returns([]) }
      it 'returns false' do
        subject.must_equal(false)
      end
    end

    after { pool.unstub }
  end

  describe '#room_for_more?' do
    subject { pool.room_for_more? }

    context 'when local workers less than max' do
      before { pool.expects(:workers).returns(['test']) }

      context 'and worker_processes less than global_max' do
        before { pool.expects(:worker_processes).returns([]) }
        it 'returns true' do
          subject.must_equal(true)
        end
      end
    end

    context 'when local workers greater than max' do
      before { pool.expects(:workers).returns(['test']*10) }
      it 'returns false' do
        subject.must_equal(false)
      end
    end

    context 'when worker_processes exceeds global_max' do
      before do
        pool.expects(:workers).returns(['test'])
        pool.expects(:global_max).twice.returns(3)
        pool.expects(:worker_processes).returns(['test']*3)
      end

      it 'returns false' do
        subject.must_equal(false)
      end
    end
  end

  describe '#spawn!' do
    before do
      @worker = Resque::Plugins::Resqued::Worker.new(pool: pool)

      pool.worker_group.expects(:worker_options).at_least_once.returns({})
      Resque::Plugins::Resqued::Worker.expects(:new).with(pool: pool).returns(@worker)
      pool.expects(:register).with(@worker).returns(true)
      @worker.expects(:alive?).returns(true)
    end

    # sorry about this, but the actual validations are in the before block.
    # TODO - refactor
    it 'creates a new worker, checks to see if it is alive, and registers it' do
      pool.send(:spawn!)
    end

    after do
      pool.worker_group.unstub(:worker_options)
      Resque::Plugins::Resqued::Worker.unstub(:new)
      pool.unstub(:register)
      @worker.unstub(:alive?)
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
      global_max:  15,
      min:         2,
      max:         4,
      first_at:    10
    } }
    subject { Resque::Plugins::Resqued::Pool.new(options) }

    it 'sets proper global_max' do
      subject.global_max.must_equal options[:global_max]
    end

    it 'sets proper min size' do
      subject.min.must_equal options[:min]
    end

    it 'sets proper max size' do
      subject.max.must_equal options[:max]
    end

    it 'sets proper first_at' do
      subject.first_at.must_equal options[:first_at]
    end
  end
end