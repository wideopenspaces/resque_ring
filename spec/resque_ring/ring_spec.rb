require 'spec_helper'
require 'benchmark'

describe ResqueRing::Ring do
  context 'a new Ring' do
    # let(:config)  { './spec/support/config_with_delay.yml' }
    let(:ring)    { ResqueRing::Ring.new({}) }
    let(:manager) { ResqueRing::Manager.new }

    before do
      ResqueRing::Manager.stubs(:new).returns(Object.new)
      manager.stubs(:delay).returns(2)
      manager.stubs(:run!).returns(true)
      ResqueRing::Ring.any_instance.stubs(:manager).returns(manager)
    end

    context '#run' do
      before { ring.expects(:run_unless_retired).returns(nil) }

      context 'when there is no manager running' do
        before { ring.manager = nil }
        it 'hires a new manager' do
          ring.expects(:hire_manager).with(ring.options).returns(manager)
          ring.run
        end
      end

      context 'when a manager is running' do
        before do
          manager.stubs(:delay).returns(1)
          ring.manager.expects(:run!).returns(true)
          ring.expects(:handle_signals).at_least_once.returns(true)
        end

        it 'calls @manager.run!' do
          # expectation in before block
          ring.run
        end

        it 'calls #productive_sleep with the correct delay' do
          ring.expects(:productive_sleep).with(manager.delay)
          ring.run
        end

        it 'calls #handle_signals the appropriate number of times' do
          Kernel.expects(:sleep).with(1).returns(1)
          ring.expects(:handle_signals).once.returns(true)
          ring.run
        end

        it 'calls run_unless_retired' do
          # expectation in before block
          ring.run
        end
      end
    end

    context '#continue!' do
      it 'tells @manager to continue' do
        ring.manager.expects(:continue!).returns(nil)
        ring.continue!
      end
    end

    context '#downsize!' do
      it 'tells @manager to downsize' do
        ring.manager.expects(:downsize!).returns(nil)
        ring.downsize!
      end
    end

    context '#fire_manager' do
      it 'tells @manager to downsize' do
        ring.manager.expects(:downsize!).returns(nil)
        ring.fire_manager
      end
    end

    context '#hire_manager' do
      it 'ensures @options is set' do
        ring.hire_manager({})
        ring.options.wont_be_nil
      end

      it 'raises an error if @options is nil' do
        ring.options = nil
        proc { ring.hire_manager(nil) }.must_raise StandardError
      end

      it 'sets @manager to a new instance of Manager with options' do
        ResqueRing::Manager.expects(:new).with({})
        ring.hire_manager({})
      end
    end

    context '#pause!' do
      before do
        ring.manager.expects(:pause!).returns(true)
        ring.manager.expects(:downsize!).returns(nil)
      end

      it 'tells @manager to pause' do
        ring.pause! # verifications above
      end

      it 'tells manager to downsize' do
        ring.pause! # verifications above
      end
    end

    context '#reload!' do
      it 'calls fire_manager' do
        ring.expects(:fire_manager).returns(nil)
        ring.reload!
      end
    end

    context '#retire!' do
      before { ring.expects(:fire_manager).returns(nil) }

      it 'sets @retired to true' do
        ring.retire!
        ring.retired?.must_equal(true)
      end

      it 'calls fire_manager' do
        ring.retire! # validated in before block
      end
    end

    context '#productive_sleep' do
      let(:code_block) { ->{ puts "stuff" } }

      context 'called with a block' do
        it 'loops until delay, executing block each time' do
          IO.expects(:puts).with("stuff").times(2).returns(nil)
          ring.productive_sleep(2) { code_block }
        end

        # TODO: figure out a better way to implement this test?
        it 'is reasonably precise' do
          time_taken = Benchmark.realtime do
            ring.productive_sleep(2) { sleep 0.66 }
          end
          time_taken.must_be_within_delta 2, 0.1
        end
      end
    end

    context '.catch_signal' do
      it 'adds the signal to Global.signals' do
        ResqueRing::Ring.catch_signal('INT')
        ResqueRing::Globals.signals.must_include 'INT'
      end
    end
  end
end
