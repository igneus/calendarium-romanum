require_relative 'spec_helper'

describe Calendar do

  describe 'core functions' do
    before :all do
      @c = Calendar.new 2013
    end

    describe '#==' do
      it 'considers calendars with the same year same' do
        Calendar.new(2014).should == Calendar.new(2014)
      end

      it 'considers calendars with different year different' do
        Calendar.new(2014).should_not == Calendar.new(2010)
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
      it 'returns a Day' do
        @c.day(2013, 12, 10).should be_a Day
      end

      it 'inserts correct year if not given' do
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

      describe 'Temporale x Sanctorale resolution' do
        before :all do
          @s = Sanctorale.new
          loader = SanctoraleLoader.new
          loader.load_from_file(@s, File.join(File.dirname(__FILE__), '..', 'data', 'universal-en.txt'))
          @c = Calendar.new 2013, @s
        end

        it '"empty" day results in a ferial' do
          d = @c.day(7, 2)
          expect(d.celebrations.size).to eq 1
          expect(d.celebrations[0].rank).to eq FERIAL
        end

        it 'sanctorale feast' do
          d = @c.day(7, 3)
          expect(d.celebrations.size).to eq 1
          expect(d.celebrations[0].rank).to eq FEAST_GENERAL
          expect(d.celebrations[0].title).to include 'Thomas'
        end

        it 'optional memorial does not suppress ferial' do
          d = @c.day(7, 14)
          expect(d.celebrations.size).to eq 2

          expect(d.celebrations[0].rank).to eq FERIAL

          expect(d.celebrations[1].rank).to eq MEMORIAL_OPTIONAL
          expect(d.celebrations[1].title).to include 'Lellis'
        end

        it 'obligate memorial does suppress ferial' do
          d = @c.day(1, 17)
          expect(d.celebrations.size).to eq 1

          expect(d.celebrations[0].rank).to eq MEMORIAL_GENERAL
        end

        it 'Sunday suppresses feast' do
          san = Sanctorale.new

          d = Date.new 2015, 6, 28
          expect(d).to be_sunday # ensure
          san.add d.month, d.day, Celebration.new('St. None, programmer', FEAST_GENERAL)

          c = Calendar.new 2014, san

          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0].rank).to eq SUNDAY_UNPRIVILEGED
        end

        it 'suppressed fictive solemnity is transferred' do
          san = Sanctorale.new

          d = Temporale.new(2014).good_friday
          st_none = Celebration.new('St. None, abbot, founder of the Order of Programmers (OProg)', SOLEMNITY_PROPER)
          san.add d.month, d.day, st_none

          c = Calendar.new 2014, san

          # Good Friday suppresses the solemnity
          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0].rank).to eq TRIDUUM
          expect(celebs[0].title).to eq 'Friday of the Passion of the Lord'

          # it is transferred on a day after the Easter octave
          d = c.temporale.easter_sunday + 8
          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0]).to eq st_none
        end

        it 'transfer of suppressed Annunciation (real world example)' do
          c = Calendar.new 2015, @s

          d = Date.new(2016, 3, 25)

          # Good Friday suppresses the solemnity
          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0].rank).to eq TRIDUUM
          expect(celebs[0].title).to eq 'Friday of the Passion of the Lord'

          # it is transferred on a day after the Easter octave
          d = c.temporale.easter_sunday + 8
          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0].title).to eq 'Annunciation of the Lord'
        end
      end
    end

    describe '#pred' do
      it 'returns a calendar for the previous year' do
        new_cal = @c.pred
        expect(new_cal.year).to eq(@c.year - 1)
        expect(new_cal.sanctorale).to eq (@c.sanctorale)
      end
    end

    describe '#succ' do
      it 'returns a calendar for the subsequent year' do
        new_cal = @c.succ
        expect(new_cal.year).to eq(@c.year + 1)
        expect(new_cal.sanctorale).to eq (@c.sanctorale)
      end
    end
  end
end
