require_relative 'spec_helper'

describe CR::Day do
  let(:d) do
    described_class.new(
      date: Date.today,
      season: CR::Seasons::ORDINARY,
      season_week: 1,
      celebrations: [CR::Celebration.new],
      vespers: vespers
    )
  end

  let(:vespers) { nil }

  describe '.new' do
    it 'works without arguments' do
      expect do
        described_class.new
      end.not_to raise_exception
    end

    it 'makes a shallow copy of celebrations' do
      celebrations = [CR::Celebration.new]
      day = described_class.new celebrations: celebrations

      expect(day.celebrations).to eq celebrations
      expect(day.celebrations).not_to be celebrations

      expect(day.celebrations[0]).to be celebrations[0]
    end
  end

  describe '#==' do
    describe 'same content' do
      let(:d2) do
        described_class.new(
          date: Date.today,
          season: CR::Seasons::ORDINARY,
          season_week: 1,
          celebrations: [CR::Celebration.new]
        )
      end

      it 'is equal' do
        expect(d).to eq d2
      end
    end

    describe 'different content' do
      let(:d2) do
        described_class.new(
          date: Date.today,
          season: CR::Seasons::LENT,
          season_week: 1,
          celebrations: [CR::Celebration.new]
        )
      end

      it 'is different' do
        expect(d).not_to eq d2
      end
    end

    describe 'different celebrations' do
      let(:d2) do
        described_class.new(
          date: Date.today,
          season: CR::Seasons::ORDINARY,
          season_week: 1,
          celebrations: [CR::Celebration.new('another celebration')]
        )
      end

      it 'is different' do
        expect(d).not_to eq d2
      end
    end

    describe 'different Vespers' do
      let(:d2) do
        described_class.new(
          date: Date.today,
          season: CR::Seasons::ORDINARY,
          season_week: 1,
          celebrations: [CR::Celebration.new],
          vespers: CR::Temporale::CelebrationFactory.palm_sunday
        )
      end

      it 'is different' do
        expect(d).not_to eq d2
      end
    end
  end

  describe '#vespers_from_following?' do
    describe 'vespers not set' do
      it { expect(d.vespers_from_following?).to be false }
    end

    describe 'vespers set' do
      let(:vespers) { CR::Celebration.new }

      it { expect(d.vespers_from_following?).to be true }
    end
  end

  describe '#weekday' do
    let(:sunday) { Date.new 2018, 5, 20 }
    let(:saturday) { sunday - 1 }

    it 'Sunday' do
      expect(sunday).to be_sunday # make sure

      d = described_class.new(date: sunday)
      expect(d.weekday).to be 0
    end

    it 'Saturday' do
      d = described_class.new(date: saturday)
      expect(d.weekday).to be 6
    end
  end

  describe '#weekday_name' do
    let(:sunday) { Date.new 2018, 5, 20 }
    let(:saturday) { sunday - 1 }

    it 'Sunday' do
      expect(sunday).to be_sunday # make sure

      d = described_class.new(date: sunday)
      expect(d.weekday_name).to eq( I18n.t('Sunday', scope: 'weekday_name'))
    end

    it 'Saturday' do
      d = described_class.new(date: saturday)
      expect(d.weekday_name).to eq( I18n.t('Saturday', scope: 'weekday_name'))
    end
  end
end
