require_relative 'spec_helper'

describe Calendar do

  describe 'core functions' do
    before :each do
      @c = Calendar.new 2013
    end

    describe '#dt_range' do
      it 'includes days of the year' do
        @c.dt_range.should include Date.new(2013, 12, 3)
       
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
      end
    end
  end
end
