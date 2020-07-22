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

        expect(temporale[date].symbol).to be :christ_eternal_priest
      end
    end
  end
end
