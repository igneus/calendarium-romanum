require_relative 'spec_helper'

describe 'Temporale extensions' do
  let(:extension) { described_class }

  describe CR::Temporale::Extensions::ChristEternalPriest do
    {
      2018 => Date.new(2019, 6, 13),
      2019 => Date.new(2020, 6, 4),
    }.each_pair do |year, date|
      it year.to_s do
        temporale = CR::Temporale.new year, extensions: [extension]

        celebration = temporale[date]
        expect(celebration.symbol).to be :christ_eternal_priest
        expect(celebration.title).to have_translation 'Our Lord Jesus Christ, The Eternal High Priest'
      end
    end
  end

  describe CR::Temporale::Extensions::DedicationBeforeAllSaints do
    known_dates = {
      2018 => Date.new(2019, 10, 27),
      2019 => Date.new(2020, 10, 25),
    }

    shared_examples 'with standard contents' do
      known_dates.each_pair do |year, date|
        it year.to_s do
          temporale = CR::Temporale.new year, extensions: [extension]

          celebration = temporale[date]
          expect(celebration.symbol).to be :dedication
          expect(celebration.title).to have_translation 'Anniversary of Dedication'
        end
      end
    end

    describe 'as class' do
      include_examples 'with standard contents'
    end

    describe 'as instance with default options' do
      let(:extension) { described_class.new }

      include_examples 'with standard contents'
    end

    describe 'as instance' do
      let(:extension) { described_class.new title: 'Custom title', symbol: :custom_symbol }

      known_dates.each_pair do |year, date|
        it year.to_s do
          temporale = CR::Temporale.new year, extensions: [extension]

          celebration = temporale[date]
          expect(celebration.symbol).to be :custom_symbol
          expect(celebration.title).to have_translation 'Custom title'
        end
      end
    end
  end
end
