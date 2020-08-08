require_relative 'spec_helper'

describe CR::Celebration do
  describe '.new' do
    it 'can be executed without arguments, sets defaults' do
      c = described_class.new

      expect(c.title).to eq ''
      expect(c.rank).to be CR::Ranks::FERIAL
      expect(c.colour).to be CR::Colours::GREEN
      expect(c.symbol).to be nil
      expect(c.date).to be nil
      expect(c.cycle).to be :sanctorale
    end

    it 'accepts positional arguments' do
      c = described_class.new(
        'Title',
        CR::Ranks::FEAST_PROPER,
        CR::Colours::RED,
        :none,
        CR::AbstractDate.new(1, 11),
        :temporale
      )

      expect(c.title).to eq 'Title'
      expect(c.rank).to be CR::Ranks::FEAST_PROPER
      expect(c.colour).to be CR::Colours::RED
      expect(c.symbol).to be :none
      expect(c.date).to eq CR::AbstractDate.new(1, 11)
      expect(c.cycle).to be :temporale
    end

    it 'accepts keyword arguments' do
      c = described_class.new(
        title: 'Title',
        rank: CR::Ranks::FEAST_PROPER,
        colour: CR::Colours::RED,
        symbol: :none,
        date: CR::AbstractDate.new(1, 11),
        cycle: :temporale
      )

      expect(c.title).to eq 'Title'
      expect(c.rank).to be CR::Ranks::FEAST_PROPER
      expect(c.colour).to be CR::Colours::RED
      expect(c.symbol).to be :none
      expect(c.date).to eq CR::AbstractDate.new(1, 11)
      expect(c.cycle).to be :temporale
    end

    it 'accepts mix of positional and keyword arguments' do
      c = described_class.new(
        'Title',
        CR::Ranks::FEAST_PROPER,
        CR::Colours::RED,
        symbol: :none,
        date: CR::AbstractDate.new(1, 11),
        cycle: :temporale
      )

      expect(c.title).to eq 'Title'
      expect(c.rank).to be CR::Ranks::FEAST_PROPER
      expect(c.colour).to be CR::Colours::RED
      expect(c.symbol).to be :none
      expect(c.date).to eq CR::AbstractDate.new(1, 11)
      expect(c.cycle).to be :temporale
    end

    it 'keyword arguments win over positional ones' do
      c = described_class.new(
        # positional arguments (won't take effect)
        'Another Title',
        CR::Ranks::MEMORIAL_GENERAL,
        CR::Colours::WHITE,
        :nullus,
        CR::AbstractDate.new(2, 22),
        :sanctorale,
        # keyword arguments
        title: 'Title',
        rank: CR::Ranks::FEAST_PROPER,
        colour: CR::Colours::RED,
        symbol: :none,
        date: CR::AbstractDate.new(1, 11),
        cycle: :temporale
      )

      expect(c.title).to eq 'Title'
      expect(c.rank).to be CR::Ranks::FEAST_PROPER
      expect(c.colour).to be CR::Colours::RED
      expect(c.symbol).to be :none
      expect(c.date).to eq CR::AbstractDate.new(1, 11)
      expect(c.cycle).to be :temporale
    end

    it 'fails loudly on unexpected keyword arguments' do
      expect { described_class.new(title: 'Title', unexpected: 'value', another: 2) }
        .to raise_exception(ArgumentError, 'Unexpected keyword arguments: [:unexpected, :another]')
    end
  end

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
    let(:tc) { described_class.new(cycle: :temporale) }
    let(:sc) { described_class.new(cycle: :sanctorale) }
    let(:nc) { described_class.new(cycle: anything) }

    it { expect(tc.temporale?).to be true }
    it { expect(tc.sanctorale?).to be false }

    it { expect(sc.sanctorale?).to be true }
    it { expect(sc.temporale?).to be false }

    it { expect(nc.sanctorale?).to be false }
    it { expect(nc.temporale?).to be false }
  end

  describe '#to_s' do
    it do
      I18n.with_locale(:en) do
        celebration = CR::PerpetualCalendar.new[Date.new(2000, 1, 8)].celebrations[0]
        expect(celebration.to_s).to eq "#<CalendariumRomanum::Celebration @title=\"Saturday after Epiphany\" @rank=#<CalendariumRomanum::Rank @priority=3.13 desc=\"Ferials\"> @colour=#<CalendariumRomanum::Colour white> symbol=nil date=nil cycle=:temporale>"
      end
    end
  end
end
