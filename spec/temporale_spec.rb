require_relative 'spec_helper'

describe Temporale do

  before :each do
    @t = Temporale.new 2012
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
end
