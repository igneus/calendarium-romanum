require 'spec_helper'

describe CR::Colour do
  CR::Colours.each do |colour|
    describe colour do
      describe '#name' do
        it { expect(colour.name).to have_translation }
      end
    end
  end

  describe 'indexing' do
    it 'is indexed by symbol' do
      expect(CR::Colours[:red]).to be CR::Colours::RED
    end
  end
end
