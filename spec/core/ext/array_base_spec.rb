require 'spec_helper'

describe Array do
  scales = 'Every good boy deserves fudge'
  let(:list) { scales.split.map(&:to_sym) }

  context '#contains?' do
    context 'given values that all exist in list' do
      it 'returns true' do
        list.contains?(:good, :boy, :fudge).must_equal(true)
      end
    end

    context 'given values that exist but in different order' do
      it 'returns true' do
        list.contains?(:fudge, :Every, :boy).must_equal(true)
      end
    end
  end
end
