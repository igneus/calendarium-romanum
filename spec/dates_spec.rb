require_relative 'spec_helper'

describe CR::Temporale::Dates do
  let(:today) { Date.new 2014, 3, 16 }

  describe '.weekday_before' do
    describe 'works well for all 7 weekdays' do
      [
        [0, Date.new(2014, 3, 9)],
        [1, Date.new(2014, 3, 10)],
        [2, Date.new(2014, 3, 11)],
        [3, Date.new(2014, 3, 12)],
        [4, Date.new(2014, 3, 13)],
        [5, Date.new(2014, 3, 14)],
        [6, Date.new(2014, 3, 15)],
      ].each do |e|
        day_num, expected = e
        it day_num do
          actual = described_class.weekday_before(day_num, today)
          expect(actual).to eq expected
        end
      end
    end
  end

  describe '.weekday_after aliases' do
    describe 'works well for all 7 weekdays' do
      [
        [:monday_after, Date.new(2014, 3, 17)],
        [:tuesday_after, Date.new(2014, 3, 18)],
        [:wednesday_after, Date.new(2014, 3, 19)],
        [:thursday_after, Date.new(2014, 3, 20)],
        [:friday_after, Date.new(2014, 3, 21)],
        [:saturday_after, Date.new(2014, 3, 22)],
        [:sunday_after, Date.new(2014, 3, 23)],
      ].each do |e|
        method, expected = e
        it method do
          actual = described_class.public_send(method, today)
          expect(actual).to eq expected
        end
      end
    end
  end

  describe 'transferable solemnities' do
    # for sake of simplicity a year has been chosen when
    # none of the transferable solemnities falls on a Sunday
    let(:year) { 2013 }

    %i(epiphany ascension corpus_christi).each do |solemnity|
      it solemnity.to_s do
        transferred =
          described_class.public_send(solemnity, year, sunday: true)
        not_transferred =
          described_class.public_send(solemnity, year)

        expect(transferred).not_to eq not_transferred
        expect(transferred).to be_sunday
      end
    end

    it 'Baptism of the Lord' do
      transferred =
          described_class.baptism_of_lord(year, epiphany_on_sunday: true)
      not_transferred =
        described_class.baptism_of_lord(year)

      expect(transferred).to be_monday
      expect(not_transferred).to be_sunday
    end
  end
end
