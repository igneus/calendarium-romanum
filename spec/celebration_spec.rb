require_relative 'spec_helper'

describe CR::Celebration do
  describe '#==' do
    let(:c) { described_class.new('title') }

    describe 'same content' do
      let(:c2) { described_class.new('title') }

      it 'is equal' do
        expect(c).to eq c2
      end
    end

    describe 'different content' do
      let(:c2) { described_class.new('another title') }

      it 'is different' do
        expect(c).not_to eq c2
      end
    end
  end
end
