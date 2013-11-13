require 'spec_helper'

describe ResqueRing::Worker do
  context 'a new worker' do
    context 'initialized with a pool' do
      let(:pool) { ResqueRing::Pool.new({}) }
      let(:worker) { ResqueRing::Worker.new(pool: pool) }

      subject { worker }

      it 'belongs to a pool' do
        subject.pool.must_equal pool
      end

      context 'with a spawner given' do
        let(:args) { ['ruby', '-e', 'sleep'] }
        let(:worker) { ResqueRing::Worker.new(pool: pool, spawner: args, env: { rails_env: 'test' }) }
        let(:process) { ChildProcess.new }

        before do
          ChildProcess.expects(:build).with(*args).returns(process)
        end

        it 'will build the process given in the spawner' do
          worker
        end

        context '#start!' do
          before do
            worker.instance_variable_set(:@process, process)
            process.expects(:start).returns(process)
          end

          it 'will start the process given in the spawner' do
            worker.start!
          end
        end

        context '#stop!' do
          before do
            worker.instance_variable_set(:@process, process)
            process.expects(:start).returns(process)
            process.expects(:stop).returns(process)

            worker.start!
          end

          it 'will stop the process' do
            worker.stop!
          end
        end
      end
    end
  end
end