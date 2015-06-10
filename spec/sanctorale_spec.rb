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
end
