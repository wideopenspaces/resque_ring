require 'spec_helper'

describe Resque::Plugins::Resqued::Registry do
  let(:registry) { Resque::Plugins::Resqued::Registry.new }
  it 'knows its own host' do
    registry.host.must_equal(`hostname`.strip)
  end
end