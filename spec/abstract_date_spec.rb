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

  # test .new through .from_date on a complete leap year
  describe '.from_date' do
    YEAR = 2000

    it 'the test year is leap' do
      expect(Date.new(YEAR)).to be_leap
    end

    CR::Util::Year.new(YEAR).each do |date|
      it date.to_s do
        expect do
          AD.from_date date
        end.not_to raise_exception
      end
    end
  end

  describe '#<' do
    it 'days of the same month' do
      expect(AD.new(1, 1)).to be < AD.new(1, 2)
    end

    it 'the same day, different months' do
      expect(AD.new(1, 1)).to be < AD.new(2, 1)
    end

    it 'same' do
      expect(AD.new(1, 1)).not_to be < AD.new(1, 1)
    end
  end

  describe '#==' do
    it { expect(AD.new(1, 1)).to be == AD.new(1, 1) }
    it { expect(AD.new(1, 1)).not_to be == AD.new(1, 2) }
    it { expect(AD.new(1, 1) == 'instance of another class').to be false }
  end

  describe 'as a Hash key' do
    it 'different objects with the same values are considered same key' do
      h = {AD.new(1, 1) => 1}
      expect(h).to have_key AD.new(1, 1)
    end
  end
end
