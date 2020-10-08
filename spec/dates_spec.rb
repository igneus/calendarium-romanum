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

  describe '.easter_sunday' do
    describe 'computed results match known Easter dates' do
      table = nil
      File.open(File.expand_path('../data/easter_dates.txt', File.dirname(__FILE__))) do |io|
        table = CR::Temporale::EasterTable.load_from(io)
      end

      (1984..2049).each do |year|
        it year.to_s do
          expect(described_class.easter_sunday(year))
            .to eq table[year]
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

    describe 'Baptism of the Lord' do
      it 'is on Sunday if Epiphany is on it\'s usual date or earlier' do
        transferred =
          described_class.baptism_of_lord(year, epiphany_on_sunday: true)
        not_transferred =
          described_class.baptism_of_lord(year)

        expect(transferred).to eq not_transferred
      end

      it 'is transferred to Monday if Epiphany is later than on it\'s usual date' do
        year = 2016

        transferred =
          described_class.baptism_of_lord(year, epiphany_on_sunday: true)
        not_transferred =
          described_class.baptism_of_lord(year)

        expect(transferred).to be_monday
        expect(not_transferred).to be_sunday
      end
    end
  end
end
