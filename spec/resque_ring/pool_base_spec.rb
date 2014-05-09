require 'spec_helper'

describe ResqueRing::Pool do
  let(:manager)       { ResqueRing::Manager.new }
  let(:worker_group)  { ResqueRing::WorkerGroup.new('test', manager: manager) }
  let(:options)       { Hash.new.merge(worker_group: worker_group) }
  let(:pool)          { ResqueRing::Pool.new(options) }

  it 'stores a reference to its worker_group' do
    pool.worker_group.must_equal worker_group
  end

  context 'through the registry' do
    let(:worker)        { ResqueRing::Worker.new(pool: pool) }
    let(:fake_pid)      { 1001 }
    let(:localized_pid) { "#{manager.registry.host}:1001" }
    let(:pool)          { ResqueRing::Pool.new(options) }

    it 'can tell how many workers are active' do
      pool.current_workers.must_equal(0)
    end

    it 'can list the pids of the active workers' do
      pool.worker_processes.must_equal([])
    end

    context 'when registering workers' do
      let(:worker)        { ResqueRing::Worker.new(pool: pool) }
      before do
        manager.instance_variable_set(:@delay, 30)
        manager.registry.reset!(worker_group.name)

        worker.expects(:pid).returns(fake_pid)
        pool.register(worker)
      end

      it 'stores the pid' do
        pool.worker_processes.must_include(localized_pid)
      end

      it 'increments the worker count' do
        pool.current_workers.must_equal(1)
      end

      it 'updates last_spawned' do
        pool.last_spawned.wont_be_nil
      end

      it 'blocks the spawner' do
        pool.spawn_blocked?.must_equal(true)
      end

      after do
        worker.unstub(:pid)
      end
    end

    context 'when de-registering workers' do
      let(:pool)          { ResqueRing::Pool.new(options) }
      let(:worker)        { ResqueRing::Worker.new(pool: pool) }

      before do
        manager.registry.reset!(worker_group.name)
        worker.expects(:pid).at_least_once.returns(fake_pid)
        pool.register(worker)
        pool.deregister(worker)
      end

      it 'removes the pid' do
        pool.worker_processes.wont_include(localized_pid)
      end

      it 'decrements the worker count in redis' do
        pool.current_workers.must_equal(0)
      end

      after { worker.unstub(:pid) }
    end
  end

  describe '#manage' do
    let(:pool)          { ResqueRing::Pool.new(options) }

    subject { pool.manage! }

    context 'when worker_group wants to remove workers' do
      before do
        worker_group.stubs(:wants_to_remove_workers?).returns(true)
        3.times { pool.workers.unshift(ResqueRing::Worker.new(pool: pool)) }

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

        @worker = ResqueRing::Worker.new(pool: pool)

        # creates a new worker
        ResqueRing::Worker.expects(:new).at_least_once.returns(@worker)

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
        ResqueRing::Worker.unstub
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

            @worker = ResqueRing::Worker.new(pool: pool)

            # creates a new worker
            ResqueRing::Worker.expects(:new).at_least_once.returns(@worker)

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
            ResqueRing::Worker.unstub
            @worker.unstub
            pool.unstub
          end
        end
      end
    end
  end

  describe '#downsize' do
    let(:pool)          { ResqueRing::Pool.new(options) }

    before do
      @worker = ResqueRing::Worker.new(pool: pool)
      pool.instance_variable_set(:@workers, [@worker])
      pool.expects(:despawn!).with(@worker)

      ResqueRing::Utilities::Logger.expects(:info).with('terminating all workers')
    end

    it 'notifies that it is terminating workers' do
      pool.downsize
    end

    it 'terminates known workers' do
      pool.downsize
    end

    after { ResqueRing::Utilities::Logger.unstub(:info) }
  end

  describe '#able_to_spawn' do
    context 'when spawning is not blocked' do
      before { pool.expects(:spawn_blocked?).returns(false) }

      it 'returns true' do
        pool.able_to_spawn?.must_equal(true)
      end

      after { pool.unstub }
    end

    context 'when spawning is blocked' do
      before { pool.expects(:spawn_blocked?).returns(true) }

      it 'returns false' do
        pool.able_to_spawn?.must_equal(false)
      end

      after { pool.unstub }
    end
  end

  describe '#spawn_first_worker?' do
    let(:pool)          { ResqueRing::Pool.new(options) }

    before do
      pool.stubs(:min).returns(0)
      pool.worker_group.pool.stubs(:able_to_spawn?).returns(true)
    end

    subject { pool.spawn_first_worker? }

    context 'when worker processes are greater than 0' do
      before { pool.instance_variable_set(:@workers, [1, 2]) }
      it 'returns false' do
        subject.must_equal(false)
      end
    end

    context 'when no workers are present' do
      before { pool.instance_variable_set(:@workers, []) }
      context 'and first_at is present' do
        before do
          pool.stubs(:first_at).returns(5)
          pool.worker_group.pool.stubs(:first_at).returns(5)
        end

        context 'and queue size is greater than first_at' do
          before { pool.worker_group.queues.stubs(:size).returns(10) }
          it 'returns true' do
            subject.must_equal(true)
          end
        end

        context 'and queue size is equal to first_at' do
          before { pool.worker_group.queues.stubs(:size).returns(5) }
          it 'returns true' do
            subject.must_equal(true)
          end
        end

        context 'and queue size is less than first_at' do
          before { pool.worker_group.queues.stubs(:size).returns(1) }
          it 'returns false' do
            subject.must_equal(false)
          end
        end
      end
    end
  end


  describe '#min_workers_spawned?' do
    let(:pool)          { ResqueRing::Pool.new(options) }

    before  { pool.stubs(:min).returns(1) }
    subject { pool.min_workers_spawned? }

    context 'when worker processes are greater than min' do
      before { pool.instance_variable_set(:@workers, [1, 2, 3]) }
      it 'returns true' do
        subject.must_equal(true)
      end
    end

    context 'when worker_processes are the same as min' do
      before { pool.instance_variable_set(:@workers, [3]) }
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
    let(:pool)          { ResqueRing::Pool.new(options) }

    subject { pool.room_for_more? }

    context 'when local workers less than max' do
      before { pool.expects(:workers).returns(['test']) }

      context 'and worker_processes less than global_max' do
        before { pool.expects(:worker_processes).returns([]) }
        it 'returns true' do
          subject.must_equal(true)
        end
      end

      after { pool.unstub }
    end

    context 'when local workers greater than max' do
      before { pool.expects(:workers).returns(['test'] * 10) }

      it 'returns false' do
        subject.must_equal(false)
      end

      after { pool.unstub }
    end

    context 'when worker_processes exceeds global_max' do
      before do
        pool.expects(:workers).returns(['test'])
        pool.expects(:global_max).twice.returns(3)
        pool.expects(:worker_processes).returns(['test'] * 3)
      end

      it 'returns false' do
        subject.must_equal(false)
      end

      after { pool.unstub }
    end
  end

  describe '#spawn!' do
    let(:pool)          { ResqueRing::Pool.new(options) }

    before do
      @worker = ResqueRing::Worker.new(pool: pool)

      pool.worker_group.expects(:worker_options).at_least_once.returns({})
      ResqueRing::Worker.expects(:new).with(pool: pool).returns(@worker)
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
      ResqueRing::Worker.unstub(:new)
      pool.unstub(:register)
      @worker.unstub(:alive?)
    end
  end

  # describe '#despawn!' do
  #   let(:pool)          { ResqueRing::Pool.new(options) }
  #
  #   before do
  #     @worker = ResqueRing::Worker.new(pool: pool)
  #     pool.send(:despawn!, @worker)
  #   end
  #
  #   it 'removes the worker from the @workers array' do
  #     pool.workers.must_not_include(@worker)
  #   end
  #
  #   it 'tells the worker to stop'
  #   it 'calls deregister with the worker as argument'
  # end

  context 'with no provided configuration' do
    let(:pool)          { ResqueRing::Pool.new(options) }

    it 'defaults to a global_max of 0' do
      pool.global_max.must_equal 0
    end

    it 'defaults to a min size of 1' do
      pool.min.must_equal 1
    end

    it 'defaults to a max size of 5' do
      pool.max.must_equal 5
    end

    it 'defaults to a first_at of 1' do
      pool.first_at.must_equal 1
    end
  end

  context 'with provided configuration' do
    let(:options) do
      {
        global_max:  15,
        min:         2,
        max:         4,
        first_at:    10
      }
    end

    subject { ResqueRing::Pool.new(options) }

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

# TODO: Test despawn
# it 'decreases the number of workers in @workers array' do
#   pool.workers.size.must_equal(0)
# end
#
# it 'removes the worker from @workers' do
#   pool.workers.wont_include(worker)
# end
