require 'spec_helper'

describe Resque::Plugins::Resqued::Manager do
  context 'a new instance' do
    context 'with no options specified' do
      subject { Resque::Plugins::Resqued::Manager.new }

      it 'responds to #run!' do
        subject.must_respond_to(:run!)
      end

      it 'sets an accessor for options that defaults to an empty hash' do
        subject.options.must_be_instance_of(Hash)
      end

      it 'has a registry' do
        subject.registry.must_be_kind_of(Resque::Plugins::Resqued::Registry)
      end
    end

    context 'with config file given' do
      let(:config) { './spec/support/config_with_delay.yml' }
      subject { Resque::Plugins::Resqued::Manager.new(config: config) }

      it 'sets the delay option specified' do
        subject.delay.must_equal(60)
      end

      it 'appropriately sets the worker_groups collection' do
        subject.worker_groups.keys.must_include(:indexing)
      end

      context 'with a worker group called indexing' do
        let(:mgr) { Resque::Plugins::Resqued::Manager.new(config: config) }
        subject { mgr.worker_groups }

        it 'contains a worker group called indexing' do
          subject[:indexing].wont_be_nil
        end

        context 'creates a WorkerGroup' do
          subject { mgr.worker_groups[:indexing] }

          it 'is a WorkerGroup' do
            subject.must_be_instance_of Resque::Plugins::Resqued::WorkerGroup
          end

          it 'is named with its key' do
            subject.name.must_equal 'indexing'
          end
        end
      end

      context 'on manage!' do
        let(:mgr) { Resque::Plugins::Resqued::Manager.new(config: config) }
        let(:wkgrp) { MiniTest::Mock.new }
        let(:wkgrp_two) { MiniTest::Mock.new }
        let(:worker_groups) { { 'test' => wkgrp, 'me' => wkgrp_two } }

        before do
          mgr.instance_variable_set(:@worker_groups, worker_groups)
          worker_groups.each_value { |wg| wg.expect(:manage!, true) }
        end

        it 'tells worker groups to manage themselves' do
          mgr.manage! # actual assertions happen in before/after here
        end

        after do
          worker_groups.each_value { |wg| wg.verify }
        end
      end
    end
  end
end