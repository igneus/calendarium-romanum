require_relative 'spec_helper'

describe CR::Rank do
  describe 'comparison' do
    it 'memorial x ferial' do
      expect(CR::Ranks::MEMORIAL_GENERAL).to be > CR::Ranks::FERIAL
    end
  end

  describe '[]' do
    it 'has all existing instances indexed by rank number' do
      expect(CR::Ranks[1.1]).to eq CR::Ranks::TRIDUUM
    end
  end

  describe '#<' do
    it { expect(CR::Ranks[1.2]).to be < CR::Ranks[1.1] }
    it { expect(CR::Ranks[1.1]).not_to be < CR::Ranks[1.2] }
  end

  describe '#>' do
    it { expect(CR::Ranks[1.1]).to be > CR::Ranks[1.2] }
    it { expect(CR::Ranks[1.2]).not_to be > CR::Ranks[1.1] }
  end

  describe '#==' do
    it { expect(CR::Ranks[1.2]).to be == CR::Ranks[1.2] }
    it { expect(CR::Ranks[1.2]).not_to be == CR::Ranks[1.1] }
  end

  describe 'descriptions' do
    CR::Ranks.each do |rank|
      describe "#{rank.priority} #{rank.short_desc}" do
        it 'has #desc translated' do
          expect(rank.desc).to have_translation
        end

        it 'is has #short_desc translated' do
          if rank.short_desc # not set for some ranks
            expect(rank.short_desc).to have_translation
          end
        end
      end
    end

    describe '#short_desc' do
      it 'is not always set' do
        expect(CR::Ranks[1.1].short_desc).to be_nil
      end
    end
  end

  describe '#memorial?' do
    it { expect(CR::Ranks::MEMORIAL_OPTIONAL.memorial?).to be true }
    it { expect(CR::Ranks::FERIAL.memorial?).to be false }
  end
end
