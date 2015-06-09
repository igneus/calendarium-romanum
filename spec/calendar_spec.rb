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
        @c.season(Date.new(2013, 12, 15)).should eq :advent
        @c.season(Date.new(2013, 12, 1)).should eq :advent
        @c.season(Date.new(2013, 12, 24)).should eq :advent
      end

      it 'determines Christmas' do
        @c.season(Date.new(2013, 12, 25)).should eq :christmas
        @c.season(Date.new(2014, 1, 12)).should eq :christmas
        @c.season(Date.new(2014, 1, 13)).should eq :ordinary
      end

      it 'determines Lent' do
        @c.season(Date.new(2014, 3, 4)).should eq :ordinary
        @c.season(Date.new(2014, 3, 5)).should eq :lent
        @c.season(Date.new(2014, 4, 19)).should eq :lent
        @c.season(Date.new(2014, 4, 20)).should eq :easter
      end

      it 'determines Easter time' do
        @c.season(Date.new(2014, 4, 20)).should eq :easter
        @c.season(Date.new(2014, 6, 8)).should eq :easter
        @c.season(Date.new(2014, 6, 9)).should eq :ordinary
      end
    end

    describe '#lectionary' do
      it 'detects correctly' do
        Calendar.new(2014).lectionary.should eq :B
        Calendar.new(2013).lectionary.should eq :A
        Calendar.new(2012).lectionary.should eq :C
      end
    end

    describe '#ferial_lectionary' do
      it 'detects correctly' do
        Calendar.new(2014).ferial_lectionary.should eq 1
        Calendar.new(2013).ferial_lectionary.should eq 2
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

    describe '#day' do
      it 'returns Day' do
        @c.day(2013, 12, 10).should be_a Day
      end

      it 'throws RangeError if given date not included in the year' do
        expect { @c.day(2000, 1, 1) }.to raise_error RangeError
      end

      it 'sets season correctly' do
        @c.day(2013, 12, 10).season.should eq :advent
      end
    end
  end
end
