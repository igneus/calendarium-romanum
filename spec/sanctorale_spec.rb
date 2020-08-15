require 'spec_helper'

describe CR::Sanctorale do
  let(:s) { described_class.new }

  # example celebrations
  let(:antonius) { CR::Celebration.new('S. Antonii, abbatis', CR::Ranks::MEMORIAL_GENERAL, CR::Colours::WHITE, :antonius) }
  let(:nullus) { CR::Celebration.new('S. Nullius', CR::Ranks::MEMORIAL_OPTIONAL, CR::Colours::WHITE, :nullus) }
  let(:ignotus) { CR::Celebration.new('S. Ignoti', CR::Ranks::MEMORIAL_OPTIONAL, CR::Colours::WHITE, :ignotus) }
  let(:opt_memorial) { nullus }
  let(:opt_memorial_2) { ignotus }
  let(:solemnity) { CR::Celebration.new('S. Nullius', CR::Ranks::SOLEMNITY_PROPER, CR::Colours::WHITE, :nullus_solemnity) }

  describe '#get' do
    describe 'for an empty day' do
      it 'returns an Array' do
        expect(s.get(1, 3)).to be_an Array
      end
    end

    describe 'for an unempty day' do
      before :each do
        s.add 1, 17, antonius
      end

      it 'get by month, day' do
        expect(s.get(1, 17)).to eq [antonius]
      end

      it 'get by Date' do
        expect(s.get(Date.new(2014, 1, 17))).to eq [antonius]
      end

      it 'may have more CR::Celebrations for a day' do
        [
          'S. Fabiani, papae et martyris',
          'S. Sebastiani, martyris'
        ].each {|t| s.add 1, 20, CR::Celebration.new(t, CR::Ranks::MEMORIAL_OPTIONAL) }
        expect(s.get(1, 20).size).to eq 2
      end
    end
  end

  describe '#add' do
    it 'adds a CR::Celebration to one month only' do
      s.add 1, 17, antonius
      expect(s.get(2, 17)).to be_empty
    end

    it 'does not allow month 0' do
      expect { s.add 0, 1, opt_memorial }.to raise_exception RangeError
    end

    it 'does not allow month higher than 12' do
      expect { s.add 13, 1, opt_memorial }.to raise_exception RangeError
    end

    it 'adds solemnity to a dedicated container' do
      expect { s.add 1, 13, solemnity }.to change { s.solemnities.size }.by 1
    end

    it 'does not add non-solemnity to solemnities' do
      expect { s.add 1, 13, opt_memorial }.not_to change { s.solemnities.size }
    end

    it 'fails when adding second celebration with the same symbol' do
      s.add 1, 13, antonius

      expect do
        s.add 1, 14, antonius
      end.to raise_exception ArgumentError, /duplicate symbol :antonius/
    end

    describe 'multiple celebrations on a single day' do
      it 'succeeds for any number of optional memorials' do
        s.add 1, 13, opt_memorial

        expect do
          s.add 1, 13, opt_memorial_2
        end.not_to raise_exception
      end

      it 'fails when adding a non-optional memorial' do
        s.add 1, 13, opt_memorial

        expect do
          s.add 1, 13, CR::Celebration.new('S. Ignoti', CR::Ranks::MEMORIAL_GENERAL)
        end.to raise_exception ArgumentError
      end

      it 'fails when adding to a non-optional memorial' do
        s.add 1, 13, CR::Celebration.new('S. Nullius', CR::Ranks::MEMORIAL_GENERAL)

        expect do
          s.add 1, 13, opt_memorial_2
        end.to raise_exception ArgumentError
      end

      # there used to be a bug, registering a solemnity *before*
      # checking if it can be added at all
      it 'does not modify internal state when it fails' do
        s.add 1, 13, opt_memorial

        expect do
          begin
            s.add 1, 13, CR::Celebration.new('S. Nullius', CR::Ranks::SOLEMNITY_GENERAL)
          rescue ArgumentError
          end
        end.not_to change { s.solemnities.size }
      end
    end
  end

  describe '#replace' do
    it 'replaces the original celebration(s)' do
      s.add 1, 13, opt_memorial_2
      s.replace 1, 13, [solemnity]

      expect(s.get(1, 13)).to eq [solemnity]
    end

    it 'adds solemnity to a dedicated container' do
      expect do
        s.replace 1, 13, [solemnity]
      end.to change { s.solemnities.size }.by 1
    end

    it 'removes solemnity' do
      s.add 1, 13, solemnity
      expect do
        s.replace 1, 13, [opt_memorial_2]
      end.to change { s.solemnities.size }.by(-1)
    end

    it 'does not simply save the passed Array' do
      array = [opt_memorial]
      s.replace 1, 13, array

      array << nil

      expect(s.get(1, 13)).not_to include nil
    end

    it 'accepts also an empty Array' do
      s.replace 1, 13, []

      expect(s.get(1, 13)).to eq []
    end

    describe 'duplicate symbol handling' do
      it 'fails when adding second celebration with the same symbol' do
        s.replace 1, 13, [nullus]

        expect do
          s.replace 1, 14, [nullus]
        end.to raise_exception ArgumentError, /duplicate symbols \[:nullus\]/
      end

      it 'failed attempts do not modify state of the internal symbol set' do
        s.replace 1, 14, [nullus]
        s.replace 1, 15, [ignotus]

        expect do
          s.replace 1, 14, [ignotus]
        end.to raise_exception ArgumentError, /duplicate symbols \[:ignotus\]/

        expect do
          s.replace 1, 15, [nullus]
        end.to raise_exception ArgumentError, /duplicate symbols \[:nullus\]/
      end

      it 'succeeds when celebration with the same symbol is being replaced' do
        s.replace 1, 13, [nullus]

        expect do
          s.replace 1, 13, [nullus]
        end.not_to raise_exception
      end
    end
  end

  describe '#update' do
    let(:s2) { described_class.new }

    it 'adds entries from the argument to receiver' do
      s2.add 1, 17, antonius

      expect(s).to be_empty
      s.update s2
      expect(s.size).to eq 1
    end

    it 'overwrites eventual previous content of the day' do
      s.add 1, 17, antonius
      s2.add 1, 17, opt_memorial

      s.update s2
      expect(s.get(1, 17)).to eq [opt_memorial]
    end

    it 'does not overwrite content of days for which it does not have any' do
      s.add 1, 17, antonius

      s.update s2
      expect(s.get(1, 17)).to eq [antonius]
    end

    describe 'copes with celebrations changing dates' do
      it 'to a later one' do
        # general calendar having St. Nullus on January 14th
        s.add 1, 14, nullus

        # proper calendar with a local saint St. Ignotus on January 14th
        # and St. Nullus moved to January 15th
        s2 = described_class.new
        s2.add 1, 14, ignotus
        s2.add 1, 15, nullus

        expect do
          s.update s2
        end.not_to raise_exception
      end

      it 'to an earlier one' do
        # general calendar having St. Nullus on January 14th
        s.add 1, 14, nullus

        # proper calendar with a local saint St. Ignotus on January 14th
        # and St. Nullus moved to January 13th
        s2 = described_class.new
        s2.add 1, 13, nullus
        s2.add 1, 14, ignotus

        expect do
          s.update s2
        end.not_to raise_exception
      end
    end

    it 'does not allow introducing duplicate symbols' do
      s.add 1, 14, nullus

      s2 = described_class.new
      s2.add 9, 19, nullus

      expect do
        s.update s2
      end.to raise_exception(ArgumentError, /Duplicate celebration symbols: \[:nullus\]/)

      # the uniqueness check is made at the end of the operation,
      # the instance is in an inconsistent state
      expect(s.get(1, 14)).to eq [nullus]
      expect(s.get(9, 19)).to eq [nullus]
    end

    it '(explicitly) empty day overwrites non-empty' do
      s.add 1, 14, nullus
      s2.replace 1, 14, []

      s.update s2

      expect(s.get(1, 14)).to eq []
    end

    it '(implicitly) empty day does not overwrite' do
      s.add 1, 14, nullus
      s.update s2

      expect(s.get(1, 14)).to eq [nullus]
    end

    it 'allows multiple celebrations without symbol' do
      celebration_without_symbol = CR::Celebration.new 'Without Symbol'
      expect(celebration_without_symbol.symbol).to be nil # make sure

      s.add 1, 14, celebration_without_symbol

      s2 = described_class.new
      s2.add 9, 19, celebration_without_symbol

      expect do
        s.update s2
      end.not_to raise_exception
    end
  end

  describe '#size' do
    it 'knows when the Sanctorale is empty' do
      expect(s.size).to be 0
    end

    it 'knows when there is something' do
      s.add 1, 17, antonius
      expect(s.size).to be 1
    end

    it 'celebrations on the same day' do
      s.add 1, 14, nullus
      s.add 1, 14, ignotus
      expect(s.size).to be 1
    end

    it 'celebrations on different days' do
      s.add 1, 14, nullus
      s.add 1, 15, ignotus
      expect(s.size).to be 2
    end
  end

  describe '#empty?' do
    it 'is empty at the beginning' do
      expect(s).to be_empty
    end

    it 'is never more empty once a record is entered' do
      s.add 1, 17, antonius
      expect(s).not_to be_empty
    end
  end

  describe '#each_day' do
    it 'yields each date and corresponding CR::Celebrations' do
      s.add 1, 17, antonius

      expect {|block| s.each_day(&block) }.to yield_with_args(CR::AbstractDate.new(1, 17), [antonius])
    end

    it 'can be called without a block' do
      expect(s.each_day).to be_an Enumerator
    end

    it 'by default does not yield empty days' do
      s.replace 1, 20, []

      expect {|block| s.each_day(&block) }
        .not_to yield_with_args(CR::AbstractDate.new(1, 20), [])
    end

    it 'yields empty days if asked for' do
      s.replace 1, 20, []

      expect {|block| s.each_day(true, &block) }
        .to yield_with_args(CR::AbstractDate.new(1, 20), [])
    end
  end

  describe '#freeze' do
    it 'makes the instance frozen' do
      expect(s).not_to be_frozen # make sure
      s.freeze
      expect(s).to be_frozen
    end

    it 'prevents modification' do
      s.freeze

      expect do
        s.add 1, 17, antonius
      end.to raise_exception(RuntimeError, /can't modify frozen/)
    end
  end

  describe '#==' do
    describe 'empty' do
      it 'is equal' do
        expect(described_class.new).to be == described_class.new
      end
    end

    describe 'with content' do
      let(:a) do
        s = described_class.new
        s.add 1, 17, antonius
        s
      end

      it 'different' do
        expect(a).not_to be == described_class.new
      end

      it 'same' do
        b = described_class.new
        b.add 1, 17, antonius

        expect(a).to be == b
      end
    end
  end
end
