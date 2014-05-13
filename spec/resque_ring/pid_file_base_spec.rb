require 'spec_helper'
require 'fakefs/safe'

include Mocha::ParameterMatchers

describe ResqueRing::PidFile do
  parallelize_me!

  let(:file)  { 'resque_ring.test.pid' }
  let(:pid)   { 21121 }
  let(:pidfile) { ResqueRing::PidFile }

  before do
    FakeFS.activate!
    Process.stubs(:pid).returns(pid)
  end

  context '.write' do
    it 'writes a file with the current PID' do
      pidfile.write(file)
      File.exists?(file).must_equal(true)
    end
  end

  context '.clean' do
    context 'if pidfile exists' do
      before { pidfile.write(file) }

      it 'removes the file' do
        File.exists?(file).must_equal(true)

        pidfile.clean(file)
        File.exists?(file).must_equal(false)
      end
    end

    context 'if no pidfile exists' do
      let(:badfile) { 'hahaha.test.pid' }

      it 'calls error with the right message' do
        pidfile.expects(:error).with(
          regexp_matches(/Problem deleting pidfile/), true)
        pidfile.clean(badfile)
      end

      after { pidfile.unstub(:error) }
    end
  end

  context '.pid' do
    before { pidfile.write(file) }

    it 'returns the pid' do
      pidfile.pid(file).must_equal(pid)
    end

    after { pidfile.clean(file) }
  end

  context '.with_pid' do
    context 'if file exists' do
      before { pidfile.write(file) }
      context 'and block is given' do
        it 'yields the pid to the block' do
          pidfile.with_pid(file) { |p| p }.must_equal(pid)
        end
      end
    end
  end

  context '.error' do
    let(:msg) { "Yo, it broke!" }
    before { $stderr.expects(:puts).with(msg).times(3) }

    it 'prints the message' do
      # See above
      pidfile.error(msg)
    end

    it 'exits if critical' do
      proc { pidfile.error(msg, true) }.must_raise SystemExit
    end

    it 'returns false if not critical' do
      pidfile.error(msg).must_equal(false)
    end
  end

  after { Process.unstub(:pid); FakeFS.deactivate! }
end
