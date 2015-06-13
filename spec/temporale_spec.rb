require_relative 'spec_helper'

describe Temporale do

  before :all do
    @t = Temporale.new 2012
    @t13 = Temporale.new 2013
  end

  describe '#weekday_before' do
    it 'works well for all 7 weekdays' do
      today = Date.new 2014, 3, 16
      @t.weekday_before(0, today).should eq Date.new(2014, 3, 9)
      @t.weekday_before(1, today).should eq Date.new(2014, 3, 10)
      @t.weekday_before(2, today).should eq Date.new(2014, 3, 11)
      @t.weekday_before(3, today).should eq Date.new(2014, 3, 12)
      @t.weekday_before(4, today).should eq Date.new(2014, 3, 13)
      @t.weekday_before(5, today).should eq Date.new(2014, 3, 14)
      @t.weekday_before(6, today).should eq Date.new(2014, 3, 15)
    end
  end

  describe '#weekday_after' do
    it 'works well for all 7 weekdays' do
      today = Date.new 2014, 3, 16
      @t.monday_after(today).should eq Date.new(2014, 3, 17)
      @t.tuesday_after(today).should eq Date.new(2014, 3, 18)
      @t.wednesday_after(today).should eq Date.new(2014, 3, 19)
      @t.thursday_after(today).should eq Date.new(2014, 3, 20)
      @t.friday_after(today).should eq Date.new(2014, 3, 21)
      @t.saturday_after(today).should eq Date.new(2014, 3, 22)
      @t.sunday_after(today).should eq Date.new(2014, 3, 23)
    end
  end

  describe '#advent_sunday' do
    it 'determines first Sunday of Advent' do
      [
       [2004, [11, 28]],
       [2010, [11, 28]],
       [2011, [11, 27]],
       [2012, [12, 2]],
       [2013, [12, 1]]
      ].each do |d|
        year, date = d
        @t.advent_sunday(1, year).should eq Date.new(year, *date)
      end
    end

    it 'determines second Sunday of Advent' do
      @t.advent_sunday(2, 2013).should eq Date.new(2013,12,8)
    end
  end

  describe '#second_advent_sunday' do
    # alias of advent_sunday through method_missing

    it 'determines second Sunday of Advent' do
      @t.second_advent_sunday(2013).should eq Date.new(2013,12,8)
    end
  end

  describe '#easter_sunday' do
    it 'determines Easter Sunday' do
      [
       [2003, [2004, 4, 11]],
       [2004, [2005, 3, 27]],
       [2005, [2006, 4, 16]],
       [2006, [2007, 4, 8]],
       [2014, [2015, 4, 5]]
      ].each do |d|
        year, date = d
        @t.easter_sunday(year).should eq Date.new(*date)
      end
    end
  end

  describe '#dt_range' do
    it 'includes days of the year' do
      @t.dt_range.should include Date.new(2012, 12, 3)
      @t.dt_range.should include Date.new(2013, 11, 5)
    end
  end

  describe '#season' do
    it 'determines Advent' do
      @t13.season(Date.new(2013, 12, 15)).should eq :advent
      @t13.season(Date.new(2013, 12, 1)).should eq :advent
      @t13.season(Date.new(2013, 12, 24)).should eq :advent
    end

    it 'determines Christmas' do
      @t13.season(Date.new(2013, 12, 25)).should eq :christmas
      @t13.season(Date.new(2014, 1, 12)).should eq :christmas
      @t13.season(Date.new(2014, 1, 13)).should eq :ordinary
    end

    it 'determines Lent' do
      @t13.season(Date.new(2014, 3, 4)).should eq :ordinary
      @t13.season(Date.new(2014, 3, 5)).should eq :lent
      @t13.season(Date.new(2014, 4, 19)).should eq :lent
      @t13.season(Date.new(2014, 4, 20)).should eq :easter
    end

    it 'determines Easter time' do
      @t13.season(Date.new(2014, 4, 20)).should eq :easter
      @t13.season(Date.new(2014, 6, 8)).should eq :easter
      @t13.season(Date.new(2014, 6, 9)).should eq :ordinary
    end
  end

  describe '#get' do
    it 'returns a Celebration' do
      expect(@t13.get(8, 12)).to be_a Celebration
    end

    describe 'for' do
      describe 'ferial' do

        it 'in Ordinary Time' do
          c = @t13.get(8, 12)
          expect(c.rank).to eq FERIAL
          expect(c.color).to eq GREEN
        end

        it 'in Advent' do
          c = @t13.get(12, 12)
          expect(c.rank).to eq FERIAL
          expect(c.color).to eq VIOLET
        end

        it 'in the last week of Advent' do
          c = @t13.get(12, 23)
          expect(c.rank).to eq FERIAL_PRIVILEGED
          expect(c.color).to eq VIOLET
        end

        it 'in Christmas time' do
          c = @t13.get(1, 3)
          expect(c.rank).to eq FERIAL
          expect(c.color).to eq WHITE
        end

        it 'in Lent' do
          c = @t13.get(3, 18)
          expect(c.rank).to eq FERIAL_PRIVILEGED
          expect(c.color).to eq VIOLET
        end

        it 'in Easter Time' do
          c = @t13.get(5, 5)
          expect(c.rank).to eq FERIAL
          expect(c.color).to eq WHITE
        end
      end

      describe 'Sunday' do
        it 'in Ordinary Time' do
          c = @t13.get(8, 10)
          expect(c.rank).to eq SUNDAY_UNPRIVILEGED
          expect(c.color).to eq GREEN
        end
      end
    end
  end
end
