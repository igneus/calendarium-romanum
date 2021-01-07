require_relative 'spec_helper'

describe CR::BaseTemporale do
  let(:year) { 2000 }

  describe 'definition of movable celebrations' do
    it 'has by default no celebrations, not even Easter' do
      t = described_class.new year
      celebration = t[CR::Temporale::Dates.easter_sunday(year)]
      expect(celebration.symbol).to be nil # does not have the :easter_sunday symbol
    end

    it 'has celebrations specified in class definition' do
      cls = Class.new(described_class) do
        celebration :easter_sunday
      end

      t = cls.new year
      celebration = t[CR::Temporale::Dates.easter_sunday(year)]
      expect(celebration).to eq CR::Temporale::CelebrationFactory.easter_sunday
    end

    describe 'inheritance' do
      it 'celebrations are passed on through inheritance' do
        cls = Class.new(described_class) do
          celebration :easter_sunday
        end
        child_cls = Class.new(cls)

        t = child_cls.new year
        celebration = t[CR::Temporale::Dates.easter_sunday(year)]
        expect(celebration).to eq CR::Temporale::CelebrationFactory.easter_sunday
      end

      it 'celebrations defined in child class do not affect parent class' do
        cls = Class.new(described_class) do
          celebration :easter_sunday
        end
        child_cls = Class.new(cls) do
          celebration :holy_trinity
        end

        t = child_cls.new year
        expect(t[CR::Temporale::Dates.holy_trinity(year)])
          .to eq CR::Temporale::CelebrationFactory.holy_trinity

        pt = cls.new year
        expect(pt[CR::Temporale::Dates.holy_trinity(year)])
          .not_to eq CR::Temporale::CelebrationFactory.holy_trinity
      end
    end

    describe '.celebration method signature' do
      it 'optional block used to build the celebration' do
        expected_value = CR::Celebration.new

        cls = Class.new(described_class) do
          celebration :easter_sunday do
            expected_value
          end
        end

        t = cls.new year
        celebration = t[CR::Temporale::Dates.easter_sunday(year)]
        expect(celebration).to be expected_value
      end

      it 'optional argument computing date' do
        date_proc = double(Proc)
        expect(date_proc).to receive(:call).and_return(Date.new(2000, 12, 1))

        cls = Class.new(described_class) do
          celebration :easter_sunday, date: date_proc
        end

        t = cls.new year
        celebration = t[Date.new(2000, 12, 1)]
        expect(celebration).to eq CR::Temporale::CelebrationFactory.easter_sunday
      end
    end

    describe 'custom dates provider' do
      it 'is used' do
        dates = double(easter_sunday: Date.new(2000, 12, 1))

        cls = Class.new(described_class) do
          celebration_dates dates
          celebration :easter_sunday
        end

        t = cls.new year
        celebration = t[Date.new(2000, 12, 1)]
        expect(celebration).to eq CR::Temporale::CelebrationFactory.easter_sunday
      end

      it 'is passed on through inheritance' do
        dates = double(easter_sunday: Date.new(2000, 12, 1))

        cls = Class.new(described_class) do
          celebration_dates dates
          celebration :easter_sunday
        end
        child_cls = Class.new(cls)

        t = child_cls.new year
        celebration = t[Date.new(2000, 12, 1)]
        expect(celebration).to eq CR::Temporale::CelebrationFactory.easter_sunday
      end

      it 'is used until another one is set' do
        dates = double(easter_sunday: Date.new(2000, 12, 1))
        dates_2 = double(holy_trinity: Date.new(2000, 12, 2))

        cls = Class.new(described_class) do
          celebration_dates dates
          celebration :easter_sunday

          celebration_dates dates_2
          celebration :holy_trinity
        end

        t = cls.new year
        celebration = t[Date.new(2000, 12, 1)]
        expect(celebration).to eq CR::Temporale::CelebrationFactory.easter_sunday
        celebration = t[Date.new(2000, 12, 2)]
        expect(celebration).to eq CR::Temporale::CelebrationFactory.holy_trinity
      end
    end

    describe 'custom celebration factory' do
      it 'is used' do
        expected = CR::Celebration.new(symbol: :whatever)
        factory = double(easter_sunday: expected)

        cls = Class.new(described_class) do
          celebration_factory factory
          celebration :easter_sunday
        end

        t = cls.new year
        celebration = t[CR::Temporale::Dates.easter_sunday(year)]
        expect(celebration).to be expected
      end

      it 'is passed on through inheritance' do
        expected = CR::Celebration.new(symbol: :whatever)
        factory = double(easter_sunday: expected)

        cls = Class.new(described_class) do
          celebration_factory factory
          celebration :easter_sunday
        end
        child_cls = Class.new(cls)

        t = child_cls.new year
        celebration = t[CR::Temporale::Dates.easter_sunday(year)]
        expect(celebration).to be expected
      end

      it 'is used until another one is set' do
        expected_easter = CR::Celebration.new(symbol: :e)
        factory = double(easter_sunday: expected_easter)

        expected_trinity = CR::Celebration.new(symbol: :t)
        factory_2 = double(holy_trinity: expected_trinity)

        cls = Class.new(described_class) do
          celebration_factory factory
          celebration :easter_sunday

          celebration_factory factory_2
          celebration :holy_trinity
        end

        t = cls.new year
        celebration = t[CR::Temporale::Dates.easter_sunday(year)]
        expect(celebration).to be expected_easter
        celebration = t[CR::Temporale::Dates.holy_trinity(year)]
        expect(celebration).to be expected_trinity
      end
    end

    describe 'custom seasons' do
      it 'is used' do
        single_season = CR::Season.new(:single, nil) { true }
        cls = Class.new(described_class) do
          set_seasons [single_season]
        end

        t = cls.new year
        t.date_range.each do |date|
          expect(t.season(date)).to be single_season
        end
      end

      it 'is passed on through inheritance' do
        single_season = CR::Season.new(:single, nil) { true }
        cls = Class.new(described_class) do
          set_seasons [single_season]
        end
        child_cls = Class.new(cls)

        t = child_cls.new year
        t.date_range.each do |date|
          expect(t.season(date)).to be single_season
        end
      end
    end

    describe 'default settings' do
      it 'deals with whole year' do
        described_class.new(2000).each_day do |date, celebration|
          expect(date).to be_a Date
          expect(celebration).to be_a CR::Celebration
        end
      end
    end
  end
end
