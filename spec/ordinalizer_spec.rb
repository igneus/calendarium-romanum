require_relative 'spec_helper'

describe CalendariumRomanum::Ordinalizer do
  describe '#ordinal' do
    describe 'English' do
      {
        1 => '1st',
        2 => '2nd',
        3 => '3rd',
        4 => '4th',
        11 => '11th',
        12 => '12th',
        13 => '13th',
        21 => '21st',
        22 => '22nd',
        23 => '23rd',
      }.each_pair do |number, ordinal|
        it number do
          expect(described_class.ordinal(number, locale: :en)).to eq ordinal
        end
      end
    end

    describe 'French' do
      {
        1 => '1er',
        2 => '2ème',
        3 => '3ème',
      }.each_pair do |number, ordinal|
        it number do
          expect(described_class.ordinal(number, locale: :fr)).to eq ordinal
        end
      end
    end
  end
end
