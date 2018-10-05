require_relative 'spec_helper'

describe CR::Celebration do
  describe '#==' do
    let(:c) { described_class.new('title') }

    describe 'same content' do
      let(:c2) { described_class.new('title') }

      it 'is equal' do
        expect(c).to eq c2
      end
    end

    describe 'different content' do
      let(:c2) { described_class.new('another title') }

      it 'is different' do
        expect(c).not_to eq c2
      end
    end
  end

  describe '#change' do
    let(:c) { described_class.new('title') }

    it 'produces a new instance' do
      c2 = c.change rank: CR::Ranks::SOLEMNITY_GENERAL
      expect(c2).not_to be c
    end

    it 'sets specified properties' do
      c2 = c.change rank: CR::Ranks::SOLEMNITY_GENERAL
      expect(c2.rank).not_to eq c.rank
      expect(c2.rank).to be CR::Ranks::SOLEMNITY_GENERAL
    end

    it 'copies the rest' do
      c2 = c.change rank: CR::Ranks::SOLEMNITY_GENERAL
      expect(c2.title).to be c.title # reference copying is no problem, Celebrations are immutable
    end
  end

  describe '#temporale?, #sanctorale?' do
    let(:tc) { described_class.new.change(cycle: :temporale) }
    let(:sc) { described_class.new.change(cycle: :sanctorale) }
    let(:nc) { described_class.new.change(cycle: anything) }

    it { expect(tc.temporale?).to be true }
    it { expect(tc.sanctorale?).to be false }

    it { expect(sc.sanctorale?).to be true }
    it { expect(sc.temporale?).to be false }

    it { expect(nc.sanctorale?).to be false }
    it { expect(nc.temporale?).to be false }
  end

  describe '#to_s' do
    celebration = CR::PerpetualCalendar.new[Date.new(2000, 1, 8)].celebrations[0]
    it { expect(celebration.to_s)
         .to eq "#<CalendariumRomanum::Celebration @title=Saturday after Epiphany @rank=#<CalendariumRomanum::Rank @priority=3.13 desc=\"Ferials\"> @colour=#<CalendariumRomanum::Colour white> @symbol= @date= @cycle=temporale>"}
  end
end
