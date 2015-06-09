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

      xit 'inserts correct year if not given' do
        expect(@c.day(12, 10).date).to eq Date.new(2013, 12, 10)
      end

      it 'throws RangeError if given date not included in the year' do
        expect { @c.day(2000, 1, 1) }.to raise_error RangeError
      end

      describe 'temporale features' do
        describe 'season' do
          it 'detects Advent correctly' do
            @c.day(2013, 12, 10).season.should eq :advent
          end
        end

        describe 'week of the season' do
          describe 'Advent' do
            it 'sets Advent week correctly' do
              expect(@c.day(2013, 12, 10).season_week).to eq 2
              expect(@c.day(2013, 12, 15).season_week).to eq 3
            end
          end

          describe 'Christmas' do
            it 'days before the first Sunday are week 0' do
              expect(@c.day(2013, 12, 25).season_week).to eq 0
            end

            it 'first Sunday starts week 1' do
              expect(@c.day(2013, 12, 29).season_week).to eq 1
            end
          end

          describe 'Lent' do
            it 'Ash Wednesday is week 0' do
              expect(@c.day(2014, 3, 5).season_week).to eq 0
            end
          end

          describe 'Easter' do
            it 'Easter Sunday opens week 1' do
              expect(@c.day(2014, 4, 20).season_week).to eq 1
            end
          end

          describe 'Ordinary time' do
            it 'Monday after Baptism of the Lord is week 1' do
              expect(@c.day(2014, 1, 13).season_week).to eq 1
            end

            it 'Continue after Pentecost' do
              expect(@c.day(2014, 6, 9).season_week).to eq 10
            end
          end
        end
      end
    end
  end
end

describe Date do
  describe 'substraction' do
    it 'returns Integer' do
      date_diff = Date.new(2013,5,5) - Date.new(2013,5,1)
      expect(date_diff).to be_a Rational
      expect(date_diff.numerator).to eq 4
    end
  end
end
