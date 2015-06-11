require 'spec_helper'

describe Sanctorale do
  before :each do
    @s = Sanctorale.new
  end

  describe '#get' do
    describe 'for empty day' do
      it 'returns an Array' do
        expect(@s.get(1,3)).to be_an Array
      end
    end

    describe 'for unempty day' do
      before :each do
        @c = Celebration.new('S. Antonii, abbatis', Ranks::MEMORIAL_GENERAL)
        @s.add 1, 17, @c
      end

      it 'get by month, day' do
        expect(@s.get(1, 17)).to eq [@c]
      end

      it 'get by Date' do
        expect(@s.get(Date.new(2014, 1, 17))).to eq [@c]
      end

      it 'can have more Celebrations for a day' do
        [
         'S. Fabiani, papae et martyris',
         'S. Sebastiani, martyris'
        ].each {|t| @s.add 1, 20, Celebration.new(t) }
        expect(@s.get(1, 20).size).to eq 2
      end
    end
  end

  describe '#add' do
    it 'adds a Celebration to one month only' do
      @s.add 1, 17, Celebration.new('S. Antonii, abbatis', Ranks::MEMORIAL_GENERAL)
      expect(@s.get(2, 17)).to be_empty
    end

    it 'does not allow month 0' do
      expect { @s.add 0, 1, Celebration.new('S. Nullius') }.to raise_exception RangeError
    end

    it 'does not allow month higher than 12' do
      expect { @s.add 13, 1, Celebration.new('S. Nullius') }.to raise_exception RangeError
    end
  end

  describe '#size' do
    it 'knows when the Sanctorale is empty' do
      expect(@s.size).to eq 0
    end

    it 'knows when there is something' do
      @s.add 1, 17, Celebration.new('S. Antonii, abbatis', Ranks::MEMORIAL_GENERAL)
      expect(@s.size).to eq 1
    end
  end

  describe '#empty?' do
    it 'is empty at the beginning' do
      expect(@s).to be_empty
    end

    it 'is never more empty once a record is entered' do
      @s.add 1, 17, Celebration.new('S. Antonii, abbatis', Ranks::MEMORIAL_GENERAL)
      expect(@s).not_to be_empty
    end
  end
end
