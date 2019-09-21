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

  describe '.each' do
    it 'yields' do
      expect {|b| described_class.each(&b) }.to yield_control
    end

    it 'yields Celebrations' do
      described_class.each do |c|
        expect(c).to be_a CR::Celebration
      end
    end

    it 'returns Enumerator if called without a block' do
      expect(described_class.each).to be_a Enumerator
    end
  end

  describe 'celebration titles are properly translated' do
    described_class.each do |celebration|
      it celebration.symbol.to_s do
        expect(celebration.title).to have_translation
      end
    end
  end
end
