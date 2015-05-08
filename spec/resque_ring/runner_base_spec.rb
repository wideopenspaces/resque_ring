require 'spec_helper'

describe ResqueRing::Runner do
  let(:runner)  { ResqueRing::Runner }
  let(:pidfile) { 'test.pid' }
  let(:args)    { ['--logfile', 'test.log',
                   '--pidfile', pidfile,
                   '--config', 'test.yml'] }

  let(:options) { Hash[*args.map { |a| a.delete('-') } ] }
  let(:mock)    { Object.new }

  before do
    ResqueRing::PidFile.stubs(:clean).returns(true)
    ResqueRing::PidFile.stubs(:with_pid).returns(true)
  end

  context '.start' do
    let(:start_args)  { args.unshift('start') }
    before do
      runner.expects(:write_pidfile).with(pidfile)

      mock.expects(:run).returns(true)
      ResqueRing::Ring.expects(:new).with(options).returns(mock)
    end

    it 'writes a pidfile' do
      # see above
      runner.start(start_args)
    end

    it 'instantiates and runs a new Ring' do
      # see above
      runner.start(start_args)
    end
  end

  context '.stop' do
    it 'sends an INT signal' do
      send_and_test_signal 'INT', 'stop'
    end
  end

  context '.reload' do
    it 'sends a HUP signal' do
      send_and_test_signal 'HUP', 'reload'
    end
  end

  context '.downsize' do
    it 'sends a USR1 signal' do
      send_and_test_signal 'USR1', 'downsize'
    end
  end

  context '.pause' do
    it 'sends a STOP signal' do
      send_and_test_signal 'STOP', 'pause'
    end
  end

  context '.continue' do
    it 'sends a CONT signal' do
      send_and_test_signal 'CONT', 'continue'
    end
  end

  context '.version' do
    it 'outputs the version in green' do
      runner.expects(:say).with(ResqueRing::VERSION, :green)
    end
  end

  context 'instance methods' do
    let(:runna) { runner.new }

    context '#ask_with_default' do
      let(:statement) { "Yes?" }
      let(:default)   { "No" }

      it 'asks a question with a default' do
        runna.expects(:ask).with("#{statement} [#{default}]")
        runna.ask_with_default(statement, default)
      end

      context 'if response' do
        it 'returns response' do
          runna.stubs(:ask).returns('y')
          runna.ask_with_default('y', 'n').must_equal('y')
        end
      end

      context 'if no response' do
        it 'returns default' do
          runna.stubs(:ask)
          runna.ask_with_default('y', 'n').must_equal('n')
        end
      end
    end

    context '#signal!' do
      let(:mypid) { 99999 }

      before do
        ResqueRing::PidFile.unstub(:with_pid)
        ResqueRing::PidFile.expects(:exist?).with(pidfile).returns(true)
        ResqueRing::PidFile.expects(:pid).with(pidfile).
          at_least_once.returns(mypid)
      end

      it 'sends the correct signal to the correct pid' do
        Process.expects(:kill).with('HUP', mypid)
        runna.signal!('HUP', pidfile)
      end
    end

    context '#write_pidfile' do
      it 'asks pidfile to write a pidfile' do
        ResqueRing::PidFile.expects(:write).with(pidfile).returns(true)
        runna.write_pidfile(pidfile)
      end

      it 'removes the pidfile at exit' do
        ResqueRing::PidFile.expects(:clean).with(pidfile).returns(true)
      end
    end
  end
end

def send_and_test_signal(sig, name)
  runner.expects(:signal!).with(sig, pidfile).returns(true)
  runner.start([name])
end
