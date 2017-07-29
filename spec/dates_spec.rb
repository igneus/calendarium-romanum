require_relative 'spec_helper'

describe CR::Temporale::Dates do
  let(:d) { described_class }

  describe '#weekday_before' do
    it 'works well for all 7 weekdays' do
      today = Date.new 2014, 3, 16
      d.weekday_before(0, today).should eq Date.new(2014, 3, 9)
      d.weekday_before(1, today).should eq Date.new(2014, 3, 10)
      d.weekday_before(2, today).should eq Date.new(2014, 3, 11)
      d.weekday_before(3, today).should eq Date.new(2014, 3, 12)
      d.weekday_before(4, today).should eq Date.new(2014, 3, 13)
      d.weekday_before(5, today).should eq Date.new(2014, 3, 14)
      d.weekday_before(6, today).should eq Date.new(2014, 3, 15)
    end
  end

  describe '#weekday_after' do
    it 'works well for all 7 weekdays' do
      today = Date.new 2014, 3, 16
      d.monday_after(today).should eq Date.new(2014, 3, 17)
      d.tuesday_after(today).should eq Date.new(2014, 3, 18)
      d.wednesday_after(today).should eq Date.new(2014, 3, 19)
      d.thursday_after(today).should eq Date.new(2014, 3, 20)
      d.friday_after(today).should eq Date.new(2014, 3, 21)
      d.saturday_after(today).should eq Date.new(2014, 3, 22)
      d.sunday_after(today).should eq Date.new(2014, 3, 23)
    end
  end
end
