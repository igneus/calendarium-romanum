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
    end

    describe '#load_from_file' do
      it 'loads something from file' do
        @l.load_from_file(File.join(%w(data universal-la.txt)), @s)
        expect(@s.size).to be > 190
      end
    end
  end

  describe 'record/file format' do
    let(:record) { '4/25 f R :  S. Marci, evangelistae' }
    let(:result) { @l.send :load_line, record }

    describe 'title' do
      it 'loads it' do
        expect(result.title).to eq 'S. Marci, evangelistae'
      end
    end

    describe 'date' do
      describe 'full date as part of the record' do
        it 'loads date' do
          expect(result.date).to eq CR::AbstractDate.new(4, 25)
        end
      end

      describe 'month as heading' do
        before :each do
          @str = [
            # month heading + day-only record
            '= 1',
            '25 f : In conversione S. Pauli, apostoli',
            # record with full date specified
            '4/25 f r :  S. Marci, evangelistae',
          ].join "\n"
          @l.load_from_string @str, @s
        end

        it 'loads a month heading and uses the month for subsequent records' do
          expect(@s.get(1, 25)).not_to be_empty
        end

        it 'still allows full date specified in the record' do
          expect(@s.get(4, 25)).not_to be_empty
        end
      end
    end

    describe 'colour' do
      describe 'not specified - sets default' do
        let(:record) { '4/25 :  S. Marci, evangelistae' }
        it { expect(result.colour).to eq CR::Colours::WHITE }
      end

      describe 'sets colour if specified' do
        let(:record) { '4/25 f R :  S. Marci, evangelistae' }
        it { expect(result.colour).to eq CR::Colours::RED }
      end

      describe 'sets colour if specified (lowercase)' do
        let(:record) { '4/25 f r :  S. Marci, evangelistae' }
        it { expect(result.colour).to eq CR::Colours::RED }
      end
    end

    describe 'rank' do
      # say we specify a proper calendar of a church dedicated to St. George
      describe 'not specified - sets default' do
        let(:record) { '4/23 : S. Georgii, martyris' }
        it { expect(result.rank).to eq CR::Ranks::MEMORIAL_OPTIONAL }
      end

      describe 'sets rank if specified' do
        let(:record) { '4/23 s R : S. Georgii, martyris' }
        it { expect(result.rank).to eq CR::Ranks::SOLEMNITY_GENERAL }
      end

      describe 'sets rank if specified (uppercase)' do
        let(:record) { '4/23 S R : S. Georgii, martyris' }
        it { expect(result.rank).to eq CR::Ranks::SOLEMNITY_GENERAL }
      end

      describe 'sets exact rank if specified' do
        let(:record) { '4/23 s1.4 R : S. Georgii, martyris' }
        it { expect(result.rank).to eq CR::Ranks::SOLEMNITY_PROPER }
      end

      describe 'sets exact rank if specified only by number' do
        let(:record) { '4/23 1.4 R : S. Georgii, martyris' }
        it { expect(result.rank).to eq CR::Ranks::SOLEMNITY_PROPER }
      end
    end

    describe 'symbol' do
      describe 'not specified - sets default' do
        let(:record) { '4/23 : S. Georgii, martyris' }
        it { expect(result.symbol).to be nil }
      end

      describe 'specified - uses it' do
        let(:record) { '4/23 :george : S. Georgii, martyris' }
        it { expect(result.symbol).to be :george }
      end
    end
  end

  describe 'Celebration properties set regardless of the loaded data' do
    describe 'cycle' do
      it 'always sets it to :sanctorale' do
        str = '4/23 1.4 R : S. Georgii, martyris'
        record = @l.send :load_line, str
        expect(record.cycle).to be :sanctorale
      end
    end
  end

  describe 'invalid input' do
    describe 'syntax errors' do
      it 'invalid syntax' do
        str = 'line without standard beginning'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /Syntax error/)
      end
    end

    describe 'syntactically correct data making no sense' do
      it 'invalid month heading' do
        str = '= 13'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /Invalid month/)
      end

      it 'one more invalid month heading' do
        str = '= 0'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /Invalid month/)
      end

      it 'invalid month' do
        str = '100/25 f : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /Invalid month/)
      end

      it 'line with day only, without preceding month heading' do
        str = '25 f : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /Invalid month/)
      end

      it 'invalid day' do
        str = '1/250 f : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /Invalid day/)
      end

      it 'invalid rank' do
        str = '1/25 X : In conversione S. Pauli, apostoli'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /Syntax error/)
      end

      it 'invalid numeric rank' do
        str = '4/23 s8.4 R : S. Georgii, martyris'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /rank/)
      end

      it 'invalid combination of rank latter and number' do
        str = '4/23 m2.5 R : S. Georgii, martyris'
        expect do
          @l.load_from_string str, @s
        end.to raise_exception(CR::InvalidDataError, /rank/)
      end
    end
  end
end
