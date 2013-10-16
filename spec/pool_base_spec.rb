require 'spec_helper'

describe Resque::Plugins::Resqued::Pool do
  context 'with no provided configuration' do
    let(:options) { Hash.new }
    subject { Resque::Plugins::Resqued::Pool.new(options) }

    it 'defaults to a global_max of 0' do
      subject.global_max.must_equal 0
    end

    it 'defaults to a min size of 1' do
      subject.min.must_equal 1
    end

    it 'defaults to a max size of 5' do
      subject.max.must_equal 5
    end

    it 'defaults to a first_at of 1' do
      subject.first_at.must_equal 1
    end
  end

  context 'with provided configuration' do
    let(:options) { {
      'global_max'  => 15,
      'min'         => 2,
      'max'         => 4,
      'first_at'    => 10
    } }
    subject { Resque::Plugins::Resqued::Pool.new(options) }

    it 'sets a global_max of 15' do
      subject.global_max.must_equal options['global_max']
    end

    it 'sets a min size of 2' do
      subject.min.must_equal options['min']
    end

    it 'sets a max size of 4' do
      subject.max.must_equal options['max']
    end

    it 'sets a first_at of 10' do
      subject.first_at.must_equal options['first_at']
    end
  end
end