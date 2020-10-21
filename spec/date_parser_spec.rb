require 'spec_helper'

describe CR::CLI::DateParser do
  describe '.parse' do
    [
      ['2017-10-06', Date.new(2017, 10, 6) .. Date.new(2017, 10, 6)],
      ['2017/10/06', Date.new(2017, 10, 6) .. Date.new(2017, 10, 6)],
      ['2017-10', CR::Util::Month.new(2017, 10)],
      ['2017/10', CR::Util::Month.new(2017, 10)],
      ['2017', CR::Util::Year.new(2017)],
    ].each do |given, expected|
      it "parses '#{given}'" do
        expect(described_class.parse(given)).to eq expected
      end
    end

    it 'should not accept an invalid month' do
      date_str = '2017-15'
      expect do
        described_class.parse(date_str)
      end.to raise_exception(ArgumentError)
    end

    it 'should not accept an invalid day' do
      date_str = '2017-10-48'
      expect do
        described_class.parse(date_str)
      end.to raise_exception(ArgumentError)
    end

    it 'should not accept a non-matching string' do
      date_str = 'foobar'
      expect do
        described_class.parse(date_str)
      end.to raise_exception(ArgumentError)
    end

    it 'should not accept an empty string' do
      date_str = ''
      expect do
        described_class.parse(date_str)
      end.to raise_exception(ArgumentError)
    end
  end
end
