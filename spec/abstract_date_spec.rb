require_relative 'spec_helper'

describe CR::AbstractDate do
  AD = CR::AbstractDate

  describe '.new' do
    describe 'fails on invalid' do
      it 'month' do
        expect do
          AD.new(13, 1)
        end.to raise_exception /Invalid month/
      end

      it 'day' do
        expect do
          AD.new(1, 32)
        end.to raise_exception /Invalid day/
      end

      it 'day of month' do
        expect do
          AD.new(2, 30)
        end.to raise_exception /Invalid day/
      end
    end
  end

  describe '#<' do
    it { expect(AD.new(1, 1)).to be < AD.new(1, 2) }
    it { expect(AD.new(1, 1)).to be < AD.new(2, 1) }
    it { expect(AD.new(1, 1)).not_to be < AD.new(1, 1) }
  end

  describe '#==' do
    it { expect(AD.new(1, 1)).to be == AD.new(1, 1) }
    it { expect(AD.new(1, 1)).not_to be == AD.new(1, 2) }
  end

  describe 'as a Hash key' do
    it 'different objects with the same values are considered same key' do
      h = {AD.new(1, 1) => 1}
      expect(h).to have_key AD.new(1, 1)
    end
  end
end
