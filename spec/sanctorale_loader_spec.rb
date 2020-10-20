require 'spec_helper'

describe CR::SanctoraleLoader do
  let(:s) { CR::Sanctorale.new }
  let(:l) { CR::SanctoraleLoader.new }

  describe 'data sources' do
    describe '#load_from_string' do
      it 'loads something from a string' do
        str = '1/3 : Ss.mi Nominis Iesu'
        l.load_from_string str, s
        expect(s.size).to eq 1
      end
    end

    describe '#load_from_file' do
      it 'loads something from file' do
        l.load_from_file(File.join(%w(data universal-la.txt)), s)
        expect(s.size).to be > 190
      end
    end
  end

  describe 'record/file format' do
    let(:record) { '4/25 f R :  S. Marci, evangelistae' }
    let(:result) { l.send :load_line, record }

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
          str = [
            # month heading + day-only record
            '= 1',
            '25 f : In conversione S. Pauli, apostoli',
            # record with full date specified
            '4/25 f r :  S. Marci, evangelistae',
          ].join "\n"
          l.load_from_string str, s
        end

        it 'loads a month heading and uses the month for subsequent records' do
          expect(s.get(1, 25)).not_to be_empty
        end

        it 'still allows full date specified in the record' do
          expect(s.get(4, 25)).not_to be_empty
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
      # SanctoraleLoader may allow other rank codes (encoding Sundays, ferials etc.),
      # but here are listed all (and only) those which should actually appear in sanctorale data files.
      [
        # not specified - sets default
        ['', CR::Ranks::MEMORIAL_OPTIONAL],
        # letter code
        ['s', CR::Ranks::SOLEMNITY_GENERAL],
        ['f', CR::Ranks::FEAST_GENERAL],
        ['m', CR::Ranks::MEMORIAL_GENERAL],
        # letter code with specifying suffix
        ['sp', CR::Ranks::SOLEMNITY_PROPER],
        ['fl', CR::Ranks::FEAST_LORD_GENERAL],
        ['fp', CR::Ranks::FEAST_PROPER],
        ['mp', CR::Ranks::MEMORIAL_PROPER],
        # letter code uppercase (codes are case-insensitive)
        ['S', CR::Ranks::SOLEMNITY_GENERAL],
        # letter code + priority number
        ['s1.3', CR::Ranks::SOLEMNITY_GENERAL],
        ['s1.4', CR::Ranks::SOLEMNITY_PROPER],
        ['f2.5', CR::Ranks::FEAST_LORD_GENERAL],
        ['f2.7', CR::Ranks::FEAST_GENERAL],
        ['f2.8', CR::Ranks::FEAST_PROPER],
        ['m3.10', CR::Ranks::MEMORIAL_GENERAL],
        ['m3.11', CR::Ranks::MEMORIAL_PROPER],
        ['m3.12', CR::Ranks::MEMORIAL_OPTIONAL],
        # priority number
        ['1.3', CR::Ranks::SOLEMNITY_GENERAL],
        ['1.4', CR::Ranks::SOLEMNITY_PROPER],
        ['2.5', CR::Ranks::FEAST_LORD_GENERAL],
        ['2.7', CR::Ranks::FEAST_GENERAL],
        ['2.8', CR::Ranks::FEAST_PROPER],
        ['3.10', CR::Ranks::MEMORIAL_GENERAL],
        ['3.11', CR::Ranks::MEMORIAL_PROPER],
        ['3.12', CR::Ranks::MEMORIAL_OPTIONAL],
      ].each do |rank_code, expected|
        describe rank_code do
          describe 'in minimal context' do
            let(:record) { "4/23 #{rank_code} : S. Georgii, martyris" }
            it { expect(result.rank).to eq expected }
          end

          describe 'in ample context' do
            let(:record) { "4/23 #{rank_code} R george : S. Georgii, martyris" }
            it { expect(result.rank).to eq expected }
          end
        end
      end
    end

    describe 'symbol' do
      describe 'not specified - sets default' do
        let(:record) { '4/23 : S. Georgii, martyris' }
        it { expect(result.symbol).to be nil }
      end

      describe 'specified - uses it' do
        let(:record) { '4/23 george : S. Georgii, martyris' }
        it { expect(result.symbol).to be :george }
      end

      describe 'supported characters' do
        let(:record) { '4/29 none_123 : S. Nullius, abbatis' }
        it { expect(result.symbol).to be :none_123 }
      end
    end
  end

  describe 'Celebration properties set regardless of the loaded data' do
    describe 'cycle' do
      it 'always sets it to :sanctorale' do
        str = '4/23 1.4 R : S. Georgii, martyris'
        record = l.send :load_line, str
        expect(record.cycle).to be :sanctorale
      end
    end
  end

  describe 'invalid input' do
    describe 'syntax errors' do
      [
        ['standard line beginning missing', 'some content'],
        ['month heading - non-numeric', '= January'],
        ['invalid rank', '1/25 X : In conversione S. Pauli, apostoli'],
      ].each do |title, given|
        it title do
          expect { l.load_from_string given }
            .to raise_exception(CR::InvalidDataError, /Syntax error/)
        end
      end
    end

    describe 'syntactically correct data making no sense' do
      [
        ['month heading - number too high', '= 13', /Invalid month/],
        ['month heading - number too low', '= 0', /Invalid month/],
        ['invalid inline month', '100/25 f : In conversione S. Pauli, apostoli', /Invalid month/],
        ['no inline month, no preceding month heading', '25 f : In conversione S. Pauli, apostoli', /Invalid month/],
        ['invalid day', '1/250 f : In conversione S. Pauli, apostoli', /Invalid day/],
        ['invalid numeric rank', '4/23 s8.4 R : S. Georgii, martyris', /rank/],
        ['invalid combination of rank latter and number', '4/23 m2.5 R : S. Georgii, martyris', /rank/],
      ].each do |title, given, expected_message|
        it title do
          expect { l.load_from_string given }
            .to raise_exception(CR::InvalidDataError, expected_message)
        end
      end
    end
  end

  describe 'YAML front matter (YFM)' do
    it 'sets metadata nil if YFM is not provided' do
      expect(l.load_from_string('').metadata)
        .to be nil
    end

    it 'loads metadata if provided' do
      expect(l.load_from_string("---\nkey: value\n---").metadata)
        .to eq({'key' => 'value'})
    end

    it 'does not load metadata with no end' do
      # Since YFM is being processed on encountering the closing
      # triple-dash, YFM spanning the whole file and not properly
      # closed will not be loaded.
      # (Implementation detail and crazy edge case, may change
      # in future without warning.)
      expect(l.load_from_string("---\nkey: value").metadata)
        .to be nil
    end
  end
end
