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
    it { expect(CR::Ranks::FERIAL == 'instance of another class').to be false }
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

  describe '#optional_memorial?' do
    it { expect(CR::Ranks::MEMORIAL_OPTIONAL.optional_memorial?).to be true }

    (CR::Ranks.all - [CR::Ranks::MEMORIAL_OPTIONAL]).each do |rank|
      it { expect(rank.optional_memorial?).to be false }
    end
  end

  describe '#obligatory_memorial?' do
    it { expect(CR::Ranks::MEMORIAL_GENERAL.obligatory_memorial?).to be true }
    it { expect(CR::Ranks::MEMORIAL_PROPER.obligatory_memorial?).to be true }

    (CR::Ranks.all - [CR::Ranks::MEMORIAL_GENERAL, CR::Ranks::MEMORIAL_PROPER]).each do |rank|
      it { expect(rank.obligatory_memorial?).to be false }
    end
  end

  describe '#sunday?' do
    it { expect(CR::Ranks::SUNDAY_UNPRIVILEGED.sunday?).to be true }
    it { expect(CR::Ranks::FERIAL.sunday?).to be false }
  end

  describe '#ferial?' do
    it { expect(CR::Ranks::FERIAL.ferial?).to be true }
    it { expect(CR::Ranks::FERIAL_PRIVILEGED.ferial?).to be true }
    it { expect(CR::Ranks::MEMORIAL_OPTIONAL.ferial?).to be false }
  end

  describe '#to_s' do
    it do
      I18n.with_locale(:en) do
        expect(CR::Ranks::FERIAL.to_s)
          .to eq '#<CalendariumRomanum::Rank @priority=3.13 desc="Ferials">'
      end
    end
  end

  describe '#succ' do
    it 'returns the next rank' do
      expect(CR::Ranks::FERIAL.succ).to be CR::Ranks::MEMORIAL_OPTIONAL
    end

    it 'throws exception if there\'s no further rank' do
      expect { CR::Ranks::TRIDUUM.succ }
        .to raise_exception StopIteration
    end
  end

  describe 'it is possible to construct Range of Ranks' do
    it 'non-empty' do
      expect(CR::Ranks::FERIAL .. CR::Ranks::FEAST_GENERAL).to include CR::Ranks::MEMORIAL_PROPER
    end

    it 'empty' do
      expect((CR::Ranks::SOLEMNITY_GENERAL .. CR::Ranks::FEAST_GENERAL).to_a).to be_empty
    end
  end
end
