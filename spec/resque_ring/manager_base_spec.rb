require 'spec_helper'

describe ResqueRing::Manager do
  parallelize_me!

  context 'a new instance' do
    context 'with no options specified' do
      let(:mgr) { ResqueRing::Manager.new }

      it 'responds to #manage!' do
        mgr.must_respond_to(:manage!)
      end

      it 'sets an accessor for options that defaults to an empty hash' do
        mgr.options.must_be_instance_of(Hash)
      end

      it 'has a registry' do
        mgr.registry.must_be_kind_of(ResqueRing::Registry)
      end
    end

    context 'with config file given' do
      let(:config)  { './spec/support/config_with_delay.yml' }
      let(:mgr)     { ResqueRing::Manager.new(config: config) }

      it 'sets the delay option specified' do
        mgr.delay.must_equal(60)
      end

      it 'appropriately sets the worker_groups collection' do
        mgr.worker_groups.keys.must_include(:indexing)
      end

      context 'with a worker group called indexing' do

        let(:worker_groups) { mgr.worker_groups }

        it 'contains a worker group called indexing' do
          worker_groups[:indexing].wont_be_nil
        end

        context 'creates a WorkerGroup' do
          let(:indexing_group) { mgr.worker_groups[:indexing] }

          it 'is a WorkerGroup' do
            indexing_group.must_be_instance_of ResqueRing::WorkerGroup
          end

          it 'is named with its key' do
            indexing_group.name.must_equal 'indexing'
          end
        end
      end

      context 'management functions' do
        let(:wkgrp)         { MiniTest::Mock.new }
        let(:wkgrp_two)     { MiniTest::Mock.new }
        let(:worker_groups) { { 'test' => wkgrp, 'me' => wkgrp_two } }

        before do
          mgr.instance_variable_set(:@worker_groups, worker_groups)
        end

        describe '#manage!' do
          before do
            worker_groups.each_value { |wg| wg.expect(:manage!, true) }
          end

          it 'tells worker groups to manage themselves' do
            mgr.manage! # actual assertions happen in before/after here
          end
        end

        describe '#downsize!' do
          let(:wkgrp)         { MiniTest::Mock.new }
          let(:wkgrp_two)     { MiniTest::Mock.new }
          let(:worker_groups) { { 'test' => wkgrp, 'me' => wkgrp_two } }

          before do
            mgr.instance_variable_set(:@worker_groups, worker_groups)
            worker_groups.each_value { |wg| wg.expect(:downsize!, true) }
          end

          it 'tells each worker group to downsize!' do
            mgr.downsize!
          end
        end

        describe '#pause!' do
          it 'sets #paused? to true' do
            mgr.pause!
            mgr.paused?.must_equal(true)
          end
        end

        describe '#continue!' do
          before { mgr.pause! }

          it 'sets #paused? to false' do
            mgr.continue!
            mgr.paused?.must_equal(false)
          end
        end

        describe '#run!' do
          context 'when paused? is true' do
            before { mgr.pause! }

            it 'does not call manage!' do
              mgr.expects(:manage!).times(0)
              mgr.run!
            end
          end

          context 'when paused? is false' do
            it 'calls manage!' do
              mgr.expects(:manage!)
              mgr.run!
            end
          end
        end

        after do
          worker_groups.each_value { |wg| wg.verify }
        end
      end
    end
  end
end
