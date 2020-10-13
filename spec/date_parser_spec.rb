require 'spec_helper'

describe CR::CLI::DateParser do
  describe 'new' do
    it 'should accept a full date YYYY/MM/DD' do
      date_str = '2017/10/06'
      expect do
        described_class.new(date_str)
      end.not_to raise_exception
    end

    it 'should accept a full date YYYY-MM-DD' do
      date_str = '2017-10-06'
      expect do
        described_class.new(date_str)
      end.not_to raise_exception
    end

    it 'should accept a month range YYYY/MM' do
      date_str = '2017/10'
      expect do
        described_class.new(date_str)
      end.not_to raise_exception
    end

    it 'should accept a month range YYYY-MM' do
      date_str = '2017-10'
      expect do
        described_class.new(date_str)
      end.not_to raise_exception
    end

    it 'should accept a year range YYYY' do
      date_str = '2017'
      expect do
        described_class.new(date_str)
      end.not_to raise_exception
    end

    it 'should not accept an invalid month' do
      date_str = '2017-15'
      expect do
        described_class.new(date_str)
      end.to raise_exception(ArgumentError)
    end

    it 'should not accept an invalid day' do
      date_str = '2017-10-48'
      expect do
        described_class.new(date_str)
      end.to raise_exception(ArgumentError)
    end

    it 'should not accept a not-matching string' do
      date_str = 'foobar'
      expect do
        described_class.new(date_str)
      end.to raise_exception(ArgumentError)
    end

    it 'should not accept an empty string' do
      date_str = ''
      expect do
        described_class.new(date_str)
      end.to raise_exception(ArgumentError)
    end
  end
end
