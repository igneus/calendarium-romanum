require 'spec_helper'

describe CR::PerpetualCalendar do
  let(:pcal) { described_class.new }

  let(:date) { Date.new(2000, 1, 1) }
  let(:year) { 2000 }

  let(:sanctorale) { CR::Data::GENERAL_ROMAN.load }

  let(:factory) { CR::Temporale::CelebrationFactory }

  describe '.new' do
    describe 'with sanctorale' do
      it 'uses the sanctorale' do
        pc = described_class.new(sanctorale: sanctorale)

        calendar = pc.calendar_for_year(year)
        expect(calendar.sanctorale).to be sanctorale
      end
    end

    describe 'with temporale options' do
      it 'applies the options' do
        pc = described_class.new(temporale_options: {transfer_to_sunday: [:epiphany]})

        y = 2016
        calendar = pc.calendar_for_year(y)
        epiphany_date = CR::Temporale::Dates.epiphany(y, sunday: true)

        expect(calendar.day(epiphany_date).celebrations[0]).to eq factory.epiphany
      end
    end

    describe 'with temporale factory' do
      it 'uses the factory' do
        temporale_subcls = Class.new(CR::Temporale)
        factory = lambda {|year| temporale_subcls.new year }

        pc = described_class.new(temporale_factory: factory)
        calendar = pc.calendar_for_year(year)
        expect(calendar.temporale).to be_a temporale_subcls
      end
    end

    describe 'with both temporale factory and options' do
      it 'fails' do
        expect do
          described_class.new(
            temporale_options: {transfer_to_sunday: [:epiphany]},
            temporale_factory: lambda {|year| }
          )
        end.to raise_exception ArgumentError
      end
    end

    describe 'with cache' do
      it 'uses the supplied object as Calendar instance cache' do
        cache = {}
        pc = described_class.new(cache: cache)
        calendar = pc.calendar_for_year(year)
        expect(cache[2000]).to be calendar
      end
    end
  end

  describe '#day' do
    it 'returns a Day' do
      expect(pcal.day(Date.today)).to be_a CR::Day
    end
  end

  describe '#[]' do
    describe 'arguments' do
      describe 'single Date' do
        it 'returns a Day' do
          expect(pcal[Date.today]).to be_a CR::Day
        end
      end

      describe 'Range of Dates' do
        shared_examples 'range' do
          it 'returns an Array of Days' do
            result = pcal[range]
            expect(result).to be_an Array
            expect(result[0]).to be_a CR::Day
          end
        end

        describe 'of the same liturgical year' do
          let(:range) { Date.new(2010, 1, 1) .. Date.new(2010, 1, 5) }

          include_examples 'range'
        end

        describe 'across boundaries of the liturgical year' do
          let(:first_advent) { CR::Temporale::Dates.first_advent_sunday(2010) }
          let(:range) { (first_advent - 1) .. (first_advent + 1) }

          include_examples 'range'
        end
      end
    end
  end

  describe '#calendar_for' do
    it 'returns a Calendar' do
      expect(pcal.calendar_for(date)).to be_a CR::Calendar
    end
  end

  describe '#calendar_for_year' do
    it 'returns a Calendar' do
      expect(pcal.calendar_for_year(year)).to be_a CR::Calendar
    end
  end

  describe 'caching' do
    it 'caches calendar instances' do
      expect(CR::Calendar).to receive(:new)

      2.times { pcal.calendar_for_year(year) }
    end
  end
end
