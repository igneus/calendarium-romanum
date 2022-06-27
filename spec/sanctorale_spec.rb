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

  describe '#dup' do
    it 'returns a new Sanctorale instance' do
      copy = s.dup

      expect(copy).to be_a described_class
      expect(copy).not_to be s
    end

    it 'copies celebrations' do
      s.add 1, 17, antonius
      copy = s.dup

      celebrations = copy.get(1, 17)
      expect(celebrations.size).to be 1
      expect(celebrations[0]).to be antonius # Celebration instances are reused, not copied
    end

    it 'changes to the copy do not change the original' do
      copy = s.dup
      copy.add 1, 17, antonius
      copy.replace 1, 14, [nullus]

      expect(s.get(1, 17)).to be_empty
      expect(s.get(1, 14)).to be_empty
    end
  end

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

      it 'get by AbstractDate' do
        expect(s.get(CR::AbstractDate.new(1, 17))).to eq [antonius]
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

  describe '#merge' do
    let(:s2) { described_class.new }

    before :each do
      s.add 1, 14, nullus
      s2.add 1, 17, antonius

      s.freeze
      s2.freeze
    end

    it 'returns a new instance with celebrations from both self and the instance passed as argument' do
      merged = s.merge s2
      expect(merged.size).to eq 2

      expect(merged).not_to be s
      expect(merged).not_to be s2

      expect(merged.get(1, 14)).to eq [nullus]
      expect(merged.get(1, 17)).to eq [antonius]
    end
  end

  describe '#difference' do
    let(:a) { described_class.new }
    let(:b) { described_class.new }

    it 'returns a new instance' do
      diff = a.difference b
      expect(diff).not_to be a
      expect(diff).not_to be b
    end

    describe 'empty sanctorales' do
      it 'returns an empty instance' do
        expect(a.difference(b)).to eq described_class.new
      end
    end

    describe 'no conflicting dates' do
      before :each do
        a.add 1, 1, nullus
        b.add 1, 2, ignotus
      end

      it 'returns the content of other' do
        expect(a.difference(b)).to eq b
      end
    end

    describe 'conflicting date' do
      before :each do
        a.add 1, 1, nullus
        b.add 1, 1, ignotus
      end

      it 'returns the content of other' do
        expect(a.difference(b)).to eq b
      end
    end

    describe 'contents the same' do
      before :each do
        a.add 1, 1, nullus
        b.add 1, 1, nullus
      end

      it 'returns an empty result' do
        expect(a.difference(b)).to be_empty
      end
    end

    describe 'given day in a subset of b' do
      before :each do
        a.add 1, 1, nullus

        b.add 1, 1, nullus
        b.add 1, 1, ignotus
      end

      it 'returns the content of other' do
        expect(a.difference(b)).to eq b
      end
    end

    describe 'given day in b subset of a' do
      before :each do
        a.add 1, 1, nullus
        a.add 1, 1, ignotus

        b.add 1, 1, nullus
      end

      it 'returns the content of other' do
        expect(a.difference(b)).to eq b
      end
    end

    describe 'given day in b the same as in a, except of ordering' do
      before :each do
        a.add 1, 1, nullus
        a.add 1, 1, ignotus

        b.add 1, 1, ignotus
        b.add 1, 1, nullus
      end

      it 'returns the content of other (i.e. even a difference in ordering is considered a difference)' do
        expect(a.difference(b)).to eq b
      end
    end

    # when specific conditions are met, #difference and #merge are mutually inverse operations
    describe 'relation to #merge' do
      describe 'given dates of `b` are a superset (>=) of dates of `a`' do
        before :each do
          a.add 1, 1, antonius

          b.add 1, 1, nullus
          b.add 1, 2, ignotus
        end

        it '#merge reverses #difference, re-creating `b`' do
          diff = a.difference b
          expect(a.merge(diff)).to eq b
        end
      end

      describe 'given dates of `a` are a superset (>=) of dates of `b`' do
        before :each do
          a.add 1, 1, nullus
          a.add 1, 2, ignotus

          b.add 1, 1, antonius
        end

        it '#difference reverses #merge, re-creating `b`' do
          merged = a.merge b
          expect(a.difference(merged)).to eq b
        end
      end
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
    before :each do
      s.add 1, 17, antonius
    end

    it 'yields each date and corresponding CR::Celebrations' do
      expect {|block| s.each_day(&block) }.to yield_with_args(CR::AbstractDate.new(1, 17), [antonius])
    end

    it 'can be called without a block' do
      expect(s.each_day).to be_an Enumerator
    end
  end

  describe '#map_days' do
    before :each do
      s.add 1, 17, antonius
    end

    it 'yields date and celebrations' do
      expect {|block| s.map_days(&block) }
        .to yield_with_args(CR::AbstractDate.new(1, 17), [antonius])
    end

    it 'returns a new Sanctorale instance' do
      result = s.map_days { [nullus] }
      expect(result).to be_a described_class
      expect(result).not_to be s
    end

    it 'replaces celebrations with result of the block' do
      expected = described_class.new.tap {|s| s.add 1, 17, nullus }

      expect(s.map_days { [nullus] })
        .to eq expected
    end

    it 'empty Array deletes the day' do
      expect(s.map_days { [] })
        .to be_empty
    end

    it 'nil deletes the day' do
      expect(s.map_days { nil })
        .to be_empty
    end
  end

  describe '#map_celebrations' do
    before :each do
      s.add 1, 17, antonius
    end

    it 'yields each celebration' do
      expect {|block| s.map_celebrations(&block) }
        .to yield_with_args(antonius)
    end

    it 'returns a new Sanctorale instance' do
      result = s.map_celebrations { nullus }
      expect(result).to be_a described_class
      expect(result).not_to be s
    end

    it 'replaces celebrations with result of the block' do
      expected = described_class.new.tap {|s| s.add 1, 17, nullus }

      expect(s.map_celebrations { nullus })
        .to eq expected
    end

    it 'nil deletes the celebration' do
      expect(s.map_celebrations { nil })
        .to be_empty
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

  describe '#provides_celebration?' do
    it 'known' do
      s.add 1, 17, antonius

      expect(s.provides_celebration?(:antonius)).to be true
    end

    it 'unknown' do
      expect(s.provides_celebration?(:unknown)).to be false
    end
  end

  describe '#by_symbol' do
    it 'known' do
      s.add 1, 17, antonius

      expect(s.by_symbol(:antonius)).to eq [CR::AbstractDate.new(1, 17), antonius]
    end

    it 'unknown' do
      expect(s.by_symbol(:unknown)).to be nil
    end
  end
end
