require_relative 'spec_helper'

describe Calendar do

  describe 'core functions' do
    before :each do
      @c = Calendar.new 2013
    end

    describe '#dt_range' do
      it 'includes days of the year' do
        @c.dt_range.should include Date.new(2013, 12, 3)
        @c.dt_range.should include Date.new(2014, 11, 5)
      end
    end

    describe '#==' do
      it 'considers calendars with the same year same' do
        Calendar.new(2014).should == Calendar.new(2014)
      end

      it 'considers calendars with different year different' do
        Calendar.new(2014).should_not == Calendar.new(2010)
      end
    end

    describe '#season' do
      it 'determines Advent' do
        @c.season(Date.new(2013, 12, 15)).should eq Calendar::T_ADVENT
        @c.season(Date.new(2013, 12, 1)).should eq Calendar::T_ADVENT
        @c.season(Date.new(2013, 12, 24)).should eq Calendar::T_ADVENT
      end

      it 'determines Christmas' do
        @c.season(Date.new(2013, 12, 25)).should eq Calendar::T_CHRISTMAS
        @c.season(Date.new(2014, 1, 12)).should eq Calendar::T_CHRISTMAS
        @c.season(Date.new(2014, 1, 13)).should eq Calendar::T_ORDINARY
      end

      it 'determines Lent' do
        @c.season(Date.new(2014, 3, 4)).should eq Calendar::T_ORDINARY
        @c.season(Date.new(2014, 3, 5)).should eq Calendar::T_LENT
        @c.season(Date.new(2014, 4, 19)).should eq Calendar::T_LENT
        @c.season(Date.new(2014, 4, 20)).should eq Calendar::T_EASTER
      end

      it 'determines Easter time' do
        @c.season(Date.new(2014, 4, 20)).should eq Calendar::T_EASTER
        @c.season(Date.new(2014, 6, 8)).should eq Calendar::T_EASTER
        @c.season(Date.new(2014, 6, 9)).should eq Calendar::T_ORDINARY
      end
    end

    describe '.for_day' do
      it 'continues the previous year\'s calendar in summer' do
        Calendar.for_day(Date.new(2014, 6, 9)).should eq Calendar.new(2013)
      end

      it 'provides the current year\'s calendar in December' do
        Calendar.for_day(Date.new(2014, 12, 20)).should eq Calendar.new(2014)
      end
    end
  end
end
