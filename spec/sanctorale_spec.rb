require 'spec_helper'

describe CR::Sanctorale do
  let(:s) { described_class.new }

  # example celebrations
  let(:antonius) { CR::Celebration.new('S. Antonii, abbatis', CR::Ranks::MEMORIAL_GENERAL) }
  let(:opt_memorial) { CR::Celebration.new('S. Nullius', CR::Ranks::MEMORIAL_OPTIONAL) }
  let(:opt_memorial_2) { CR::Celebration.new('S. Ignoti', CR::Ranks::MEMORIAL_OPTIONAL) }
  let(:solemnity) { CR::Celebration.new('S. Nullius', CR::Ranks::SOLEMNITY_PROPER) }

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
  end

  describe '#size' do
    it 'knows when the Sanctorale is empty' do
      expect(s.size).to eq 0
    end

    it 'knows when there is something' do
      s.add 1, 17, antonius
      expect(s.size).to eq 1
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
