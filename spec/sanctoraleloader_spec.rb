require 'spec_helper'

describe SanctoraleLoader do

  before :each do
    @s = Sanctorale.new
    @l = SanctoraleLoader.new
  end

  describe 'data sources' do
    describe '.load_from_string' do
      before :each do
        str = '1/3 : Ss.mi Nominis Iesu'
        @l.load_from_string @s, str
      end

      it 'loads one entry' do
        expect(@s.size).to eq 1
      end

      it 'loads date correctly' do
        expect(@s.get(1, 3).size).to eq 1
      end

      it 'loads title correctly' do
        expect(@s.get(1, 3)[0].title).to eq 'Ss.mi Nominis Iesu'
      end

      it 'sets default rank' do
        expect(@s.get(1, 3)[0].rank).to eq Ranks::MEMORIAL_OPTIONAL
      end

      it 'loads explicit rank if given' do
        str = '1/25 f : In conversione S. Pauli, apostoli'
        @l.load_from_string @s, str
        expect(@s.get(1, 25)[0].rank).to eq Ranks::FEAST_GENERAL
      end
    end
  end
end
