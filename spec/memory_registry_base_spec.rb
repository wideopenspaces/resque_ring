require 'spec_helper'
require 'resqued/memory_registry'

describe Resque::Plugins::Resqued::MemoryRegistry do
  let(:registry) { Resque::Plugins::Resqued::MemoryRegistry.new }
  it 'knows its own host' do
    registry.host.must_equal(`hostname`.strip)
  end
end