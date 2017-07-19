require 'spec_helper'

describe CR::SanctoraleLoader do

  before :each do
    @s = CR::Sanctorale.new
    @l = CR::SanctoraleLoader.new
  end

  describe 'data sources' do
    describe '#load_from_string' do
      before :each do
        str = '1/3 : Ss.mi Nominis Iesu'
        @l.load_from_string str, @s
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
        expect(@s.get(1, 3)[0].rank).to eq CR::Ranks::MEMORIAL_OPTIONAL
      end

      it 'sets default colour - white' do
        expect(@s.get(1, 3)[0].colour).to eq CR::Colours::WHITE
      end

      it 'loads explicit rank if given' do
        str = '1/25 f : In conversione S. Pauli, apostoli'
        @l.load_from_string str, @s
        expect(@s.get(1, 25)[0].rank).to eq CR::Ranks::FEAST_GENERAL
      end
    end

    describe '#load_from_file' do
      it 'loads something from file' do
        @l.load_from_file(File.join(%w{data universal-la.txt}), @s)
        expect(@s.size).to be > 190
      end
    end
  end

  describe 'record/file format' do
    describe 'month as heading' do
      it 'loads a month heading and uses the month for subsequent records' do
        str = ['= 1', '25 f : In conversione S. Pauli, apostoli'].join "\n"
        @l.load_from_string str, @s
        expect(@s).not_to be_empty
        expect(@s.get(1, 25)).not_to be_empty
      end
    end

    describe 'colour' do
      it 'sets colour if specified' do
        str = '4/25 f R :  S. Marci, evangelistae'
        @l.load_from_string str, @s
        expect(@s.get(4, 25).first.colour).to eq CR::Colours::RED
      end

      it 'sets colour if specified (lowercase)' do
        str = '4/25 f r :  S. Marci, evangelistae'
        @l.load_from_string str, @s
        expect(@s.get(4, 25).first.colour).to eq CR::Colours::RED
      end
    end

    describe 'rank' do
      # say we specify a proper calendar of a church dedicated to St. George

      it 'sets rank if specified' do

        str = '4/23 s R : S. Georgii, martyris'
        @l.load_from_string str, @s
        celeb = @s.get(4, 23).first
        expect(celeb.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
      end

      it 'sets rank if specified (uppercase)' do
        str = '4/23 S R : S. Georgii, martyris'
        @l.load_from_string str, @s
        celeb = @s.get(4, 23).first
        expect(celeb.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
      end

      it 'sets exact rank if specified' do
        str = '4/23 s1.4 R : S. Georgii, martyris'
        @l.load_from_string str, @s
        celeb = @s.get(4, 23).first
        expect(celeb.rank).to eq CR::Ranks::SOLEMNITY_PROPER
      end

      it 'sets exact rank if specified only by number' do
        str = '4/23 1.4 R : S. Georgii, martyris'
        @l.load_from_string str, @s
        celeb = @s.get(4, 23).first
        expect(celeb.rank).to eq CR::Ranks::SOLEMNITY_PROPER
      end
    end
  end

  describe 'invalid input' do
    describe 'syntax errors' do
      it 'invalid syntax' do
        str = 'line without standard beginning'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /Syntax error/
      end
    end

    describe 'syntactically correct data making no sense' do
      it 'invalid month' do
        str = '100/25 f : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /Invalid month/
      end

      it 'line with day only, without preceding month heading' do
        str = '25 f : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /Invalid month/
      end

      it 'invalid day' do
        str = '1/250 f : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /Invalid day/
      end

      it 'invalid month heading' do
        str = '= 0'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /Invalid month/
      end

      it 'invalid rank' do
        str = '1/25 X : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /Syntax error/
      end

      it 'invalid numeric rank' do
        str = '4/23 s8.4 R : S. Georgii, martyris'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /rank/
      end

      it 'invalid combination of rank latter and number' do
        str = '4/23 m2.5 R : S. Georgii, martyris'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception /rank/
      end
    end
  end
end
