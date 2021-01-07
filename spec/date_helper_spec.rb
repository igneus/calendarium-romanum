require_relative 'spec_helper'

describe CR::Temporale::DateHelper do
  let(:today) { Date.new 2014, 3, 16 }

  weekday_before_examples = [
    [0, :sunday_before, Date.new(2014, 3, 9)],
    [1, :monday_before, Date.new(2014, 3, 10)],
    [2, :tuesday_before, Date.new(2014, 3, 11)],
    [3, :wednesday_before, Date.new(2014, 3, 12)],
    [4, :thursday_before, Date.new(2014, 3, 13)],
    [5, :friday_before, Date.new(2014, 3, 14)],
    [6, :saturday_before, Date.new(2014, 3, 15)],
  ]

  describe '.weekday_before' do
    weekday_before_examples.each do |day_num, method, expected|
      it "weekday number #{day_num}" do
        actual = described_class.weekday_before(day_num, today)
        expect(actual).to eq expected
      end
    end
  end

  describe '.weekday_before aliases' do
    weekday_before_examples.each do |day_num, method, expected|
      it method do
        actual = described_class.public_send(method, today)
        expect(actual).to eq expected
      end
    end
  end

  weekday_after_examples = [
    [0, :sunday_after, Date.new(2014, 3, 23)],
    [1, :monday_after, Date.new(2014, 3, 17)],
    [2, :tuesday_after, Date.new(2014, 3, 18)],
    [3, :wednesday_after, Date.new(2014, 3, 19)],
    [4, :thursday_after, Date.new(2014, 3, 20)],
    [5, :friday_after, Date.new(2014, 3, 21)],
    [6, :saturday_after, Date.new(2014, 3, 22)],
  ]

  describe '.weekday_after' do
    weekday_after_examples.each do |day_num, method, expected|
      it "weekday number #{day_num}" do
        actual = described_class.weekday_after(day_num, today)
        expect(actual).to eq expected
      end
    end
  end

  describe '.weekday_after aliases' do
    weekday_after_examples.each do |day_num, method, expected|
      it method do
        actual = described_class.public_send(method, today)
        expect(actual).to eq expected
      end
    end
  end

  describe '.octave_of' do
    [
      ['within a month', Date.new(2000, 1, 1), Date.new(2000, 1, 8)],
      ['over month boundaries', Date.new(2000, 1, 31), Date.new(2000, 2, 7)],
    ].each do |name, given, expected|
      it name do
        expect(described_class.octave_of(given)).to eq expected
      end
    end
  end
end
