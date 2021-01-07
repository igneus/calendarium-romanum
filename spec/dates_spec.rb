require_relative 'spec_helper'

describe CR::Temporale::Dates do
  let(:today) { Date.new 2014, 3, 16 }

  describe 'usage as mixin' do
    it 'can be included and provides all the solemnity date methods' do
      m = Module.new
      expect(m.public_instance_methods).not_to include :easter_sunday # make sure

      m.include described_class
      expect(m.public_instance_methods).to include :easter_sunday
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
