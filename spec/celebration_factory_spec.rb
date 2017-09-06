require 'spec_helper'

describe CR::Temporale::CelebrationFactory do
  describe '.first_advent_sunday' do
    it 'returns Celebration equal to the one returned by Temporale' do
      year = 2000
      temporale = CR::Temporale.new(year)
      date = CR::Temporale::Dates.first_advent_sunday(year)

      c = temporale.get(date)
      c2 = described_class.first_advent_sunday

      expect(c2).to eq c
    end
  end
end
