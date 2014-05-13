require 'spec_helper'
require_relative '../../support/dummy_object'

describe ResqueRing::Utilities::SignalHandler do
  parallelize_me!

  let(:dummy_object) { DummyObject.new }

  context 'the extended class' do
    it 'has a method called intercept' do
      DummyObject.respond_to?(:intercept).must_equal(true)
    end
    it 'should have a method called intercepts' do
      DummyObject.respond_to?(:intercepts).must_equal(true)
    end
  end

  context '.intercept' do
    before do
      DummyObject.send(:intercept, :int, with: :signal_handler)
    end

    it 'catches an INT signal and calls signal_handler' do
      DummyObject.expects(:signal_handler).with('INT').returns('INT')
      Process.kill('INT', Process.pid)
    end

    context 'given a bad signal' do
      let(:badwolf) { 'BDWF' }
      let(:badsig)  { badwolf.downcase.to_sym }

      it 'warns that signal is unsupported' do
        error = "Signal (#{badwolf}) is not supported. Sorry, ol' chap."
        DummyObject.expects(:warn).with(error)

        DummyObject.send(:intercept, badwolf.downcase.to_sym,
                         with: :signal_handler)
      end
    end
  end

  context '.intercepts' do
    before do
      DummyObject.send(:intercepts,
        :hup  => :hupty_hup,
        :quit => :quit_it )
    end

    it 'catches HUP and calls .hupty_hup' do
      DummyObject.expects(:hupty_hup).with('HUP')
      Process.kill('HUP', Process.pid)
    end

    it 'catches QUIT and calls .quit_it' do
      DummyObject.expects(:quit_it).with('QUIT')
      Process.kill('QUIT', Process.pid)
    end
  end
end
