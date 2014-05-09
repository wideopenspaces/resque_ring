require 'spec_helper'

describe Hash do
  scales = 'Every good boy deserves fudge'
  let(:hash) { { every: 'good', boy: 'deserves', fudge: nil } }

  context '#keys?' do
    context 'given values that all exist in keys' do
      it 'returns true' do
        hash.keys?(:every, :boy, :fudge).must_equal(true)
      end
    end

    context 'given values that exist but in different order' do
      it 'returns true' do
        hash.keys?(:fudge, :every, :boy).must_equal(true)
      end
    end
  end
end
