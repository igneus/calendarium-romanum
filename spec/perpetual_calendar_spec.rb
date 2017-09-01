require 'spec_helper'

describe CR::PerpetualCalendar do
  let(:pcal) { described_class.new }

  let(:date) { Date.new(2000, 1, 1) }
  let(:year) { 2000 }

  let(:sanctorale) { CR::Data::GENERAL_ROMAN_ENGLISH.load }

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
        expect(epiphany_date).not_to eq CR::Temporale::Dates.epiphany(y) # make sure

        expect(calendar.day(epiphany_date).celebrations[0].title).to have_translation 'The Epiphany of the Lord'
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
            temporale_factory: lambda {|year| temporale_subcls.new year }
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
