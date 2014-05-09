require 'spec_helper'

describe ResqueRing::Config do
  context 'a new Config' do
    context 'given a valid config file' do
      # Complete config
      let(:config_file) { './spec/support/config_with_delay.yml' }
      let(:config) { ResqueRing::Config.new(config_file) }

      # More minimal config
      let(:min_config) { './spec/support/config_without_delay.yml' }
      let(:min) { ResqueRing::Config.new(min_config) }

      it 'sets loaded? to true' do
        config.loaded?.must_equal(true)
      end

      context '#config' do
        it 'is an OpenStruct' do
          config.config.must_be_instance_of(OpenStruct)
        end
      end

      context '#delay' do
        context 'if delay is set in the config file' do
          it 'matches the value in the config file' do
            config.delay.must_equal(60)
          end
        end

        context 'if delay is not set in config file' do

          it 'uses a default value of 120' do
            min.delay.must_equal(120)
          end
        end
      end

      context '#redis' do
        context 'if redis key is in config file' do
          it 'matches the values present in file' do
            config.redis.must_equal({ host: '127.0.0.1', port: 6379 })
          end
        end

        context 'if redis key is not set in config' do
          it 'uses redis defaults' do
            min.redis.must_equal({ host: 'localhost', port: 6379 })
          end
        end
      end
    end
  end
end

    # context 'initialized with a pool' do
    #   let(:pool)    { ResqueRing::Pool.new({}) }
    #   let(:worker)  { ResqueRing::Worker.new(pool: pool) }
    #
    #   subject { worker }
    #
    #   it 'belongs to a pool' do
    #     subject.pool.must_equal pool
    #   end
    #
    #   context 'with a spawner given' do
    #     let(:args)    { ['ruby', '-e', 'sleep'] }
    #     let(:worker)  { ResqueRing::Worker.new(pool: pool, spawner: args, env: { rails_env: 'test' }) }
    #     let(:process) { ChildProcess.new }
    #
    #     before do
    #       ChildProcess.expects(:build).with(*args).returns(process)
    #     end
    #
    #     it 'will build the process given in the spawner' do
    #       worker
    #     end
    #
    #     context '#start!' do
    #       before do
    #         worker.instance_variable_set(:@process, process)
    #         process.expects(:start).returns(process)
    #       end
    #
    #       it 'will start the process given in the spawner' do
    #         worker.start!
    #       end
    #     end
    #
    #     context '#stop!' do
    #       before do
    #         worker.instance_variable_set(:@process, process)
    #         process.expects(:start).returns(process)
    #         process.expects(:stop).returns(process)
    #
    #         worker.start!
    #       end
    #
    #       it 'will stop the process' do
    #         worker.stop!
    #       end
    #     end
    #   end
    # end
