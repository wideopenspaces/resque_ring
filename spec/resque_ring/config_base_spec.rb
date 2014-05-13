require 'spec_helper'

describe ResqueRing::Config do
  parallelize_me!

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

      it 'sets config_file to the specified path' do
        config.source_file.must_equal(config_file)
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
            config.redis.must_equal(host: '127.0.0.1', port: 6379)
          end
        end

        context 'if redis key is not set in config' do
          it 'uses redis defaults' do
            min.redis.must_equal(host: 'localhost', port: 6379)
          end
        end
      end
    end
  end
end
