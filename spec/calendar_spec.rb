require_relative 'spec_helper'

describe CR::Calendar do

  describe 'core functions' do
    before :all do
      @c = described_class.new(2013).freeze
    end

    describe '#==' do
      it 'considers calendars with the same year same' do
        expect(described_class.new(2014) == described_class.new(2014)).to be true
      end

      it 'considers calendars with different year different' do
        expect(described_class.new(2014) == described_class.new(2010)).to be false
      end
    end

    describe '#lectionary' do
      it 'detects correctly' do
        expect(described_class.new(2014).lectionary).to eq :B
        expect(described_class.new(2013).lectionary).to eq :A
        expect(described_class.new(2012).lectionary).to eq :C
      end
    end

    describe '#ferial_lectionary' do
      it 'detects correctly' do
        expect(described_class.new(2014).ferial_lectionary).to eq 1
        expect(described_class.new(2013).ferial_lectionary).to eq 2
      end
    end

    describe '.for_day' do
      it 'continues the previous year\'s calendar in summer' do
        expect(described_class.for_day(Date.new(2014, 6, 9))).to eq described_class.new(2013)
      end

      it 'provides the current year\'s calendar in December' do
        expect(described_class.for_day(Date.new(2014, 12, 20))).to eq described_class.new(2014)
      end
    end

    describe '#day' do
      describe 'received arguments' do
        describe 'Date' do
          it 'returns a Day' do
            expect(@c.day(Date.new(2013, 12, 10))).to be_a CR::Day
          end
        end

        describe 'DateTime' do
          it 'returns a Day' do
            expect(@c.day(DateTime.new(2013, 12, 10, 12, 10, 0))).to be_a CR::Day
          end
        end

        describe 'three Integers' do
          it 'returns a Day' do
            expect(@c.day(2013, 12, 10)).to be_a CR::Day
          end
        end

        describe 'two integers' do
          describe 'autumn' do
            it 'supplies year' do
              day = @c.day(12, 10)
              expect(day).to be_a CR::Day
              expect(day.date).to eq Date.new(2013, 12, 10)
            end
          end

          describe 'spring' do
            it 'supplies year' do
              day = @c.day(4, 10)
              expect(day).to be_a CR::Day
              expect(day.date).to eq Date.new(2014, 4, 10)
            end
          end

          describe 'invalid' do
            describe 'absolutely' do
              it 'fails' do
                expect do
                  day = @c.day(0, 34)
                end.to raise_exception(ArgumentError, 'invalid date')
              end
            end

            describe 'for the given year' do
              it 'fails' do
                expect do
                  day = @c.day(2, 29)
                end.to raise_exception(ArgumentError, 'invalid date')
              end
            end
          end
        end
      end

      it 'throws RangeError if given date not included in the year' do
        expect { @c.day(2000, 1, 1) }.to raise_error RangeError
      end

      describe 'temporale features' do
        describe 'season' do
          it 'detects Advent correctly' do
            expect(@c.day(2013, 12, 10).season).to eq CR::Seasons::ADVENT
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

            describe 'after Pentecost' do
              it '2014' do
                c = described_class.new(2013)
                expect(c.day(2014, 6, 9).season_week).to eq 10
              end

              it '2015' do
                c = described_class.new(2014)
                expect(c.day(2015, 5, 25).season_week).to eq 8
              end

              it '2016' do
                c = described_class.new(2015)
                expect(c.day(2016, 5, 16).season_week).to eq 7
              end

              it '2017' do
                c = described_class.new(2016)
                expect(c.day(2017, 6, 5).season_week).to eq 9
              end

              describe 'works correctly for the whole week' do
                describe 'first' do
                  Date.new(2014, 6, 9).upto(Date.new(2014, 6, 14)) do |date|
                    it date do
                      expect(@c.day(date).season_week).to eq 10
                    end
                  end
                end

                describe 'second' do
                  Date.new(2014, 6, 15).upto(Date.new(2014, 6, 21)) do |date|
                    it date do
                      expect(@c.day(date).season_week).to eq 11
                    end
                  end
                end

                describe 'second last'  do
                  Date.new(2014, 11, 16).upto(Date.new(2014, 11, 22)) do |date|
                    it date do
                      expect(@c.day(date).season_week).to eq 33
                    end
                  end
                end

                describe 'last' do
                  Date.new(2014, 11, 23).upto(Date.new(2014, 11, 29)) do |date|
                    it date do
                      expect(@c.day(date).season_week).to eq 34
                    end
                  end
                end
              end
            end
          end
        end
      end

      describe 'Temporale x Sanctorale resolution' do
        before :all do
          @s = CR::Data::GENERAL_ROMAN_ENGLISH.load
          @c = described_class.new(2013, @s).freeze
        end

        it '"empty" day results in a ferial' do
          d = @c.day(7, 2)
          expect(d.celebrations.size).to eq 1
          expect(d.celebrations[0].rank).to eq CR::Ranks::FERIAL
        end

        it 'sanctorale feast' do
          d = @c.day(7, 3)
          expect(d.celebrations.size).to eq 1
          expect(d.celebrations[0].rank).to eq CR::Ranks::FEAST_GENERAL
          expect(d.celebrations[0].title).to include 'Thomas'
        end

        it 'optional memorial does not suppress ferial' do
          d = @c.day(7, 14)
          expect(d.celebrations.size).to eq 2

          expect(d.celebrations[0].rank).to eq CR::Ranks::FERIAL

          expect(d.celebrations[1].rank).to eq CR::Ranks::MEMORIAL_OPTIONAL
          expect(d.celebrations[1].title).to include 'Lellis'
        end

        it 'obligatory memorial does suppress ferial' do
          d = @c.day(1, 17)
          expect(d.celebrations.size).to eq 1

          expect(d.celebrations[0].rank).to eq CR::Ranks::MEMORIAL_GENERAL
        end

        it 'memorial in Lent becomes mere commemoration' do
          d = @c.day(4, 2)
          expect(d.celebrations.size).to eq 2

          comm = d.celebrations[1]
          expect(comm.rank).to eq CR::Ranks::COMMEMORATION
          expect(comm.title).to eq 'Saint Francis of Paola, hermit'
        end

        it 'Sunday suppresses feast' do
          san = CR::Sanctorale.new

          d = Date.new 2015, 6, 28
          expect(d).to be_sunday # ensure
          san.add d.month, d.day, CR::Celebration.new('St. None, programmer', CR::Ranks::FEAST_GENERAL)

          c = described_class.new 2014, san

          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0].rank).to eq CR::Ranks::SUNDAY_UNPRIVILEGED
        end

        it 'suppressed fictive solemnity is transferred' do
          san = CR::Sanctorale.new

          d = CR::Temporale.new(2014).good_friday
          st_none = CR::Celebration.new('St. None, abbot, founder of the Order of Programmers (OProg)', CR::Ranks::SOLEMNITY_PROPER)
          san.add d.month, d.day, st_none

          c = described_class.new 2014, san

          # Good Friday suppresses the solemnity
          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0].rank).to eq CR::Ranks::TRIDUUM
          expect(celebs[0].title).to have_translation 'Friday of the Passion of the Lord'

          # it is transferred on a day after the Easter octave
          d = c.temporale.easter_sunday + 8
          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0]).to eq st_none
        end

        it 'transfer of suppressed Annunciation (real world example)' do
          c = described_class.new 2015, @s

          d = Date.new(2016, 3, 25)

          # Good Friday suppresses the solemnity
          celebs = c.day(d).celebrations
          expect(celebs.size).to eq 1
          expect(celebs[0].rank).to eq CR::Ranks::TRIDUUM
          expect(celebs[0].title).to have_translation 'Friday of the Passion of the Lord'

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

      it 'preserves sanctorale' do
        sanctorale = CR::Sanctorale.new
        cal = described_class.new(2000, sanctorale)
        new_cal = cal.pred
        expect(new_cal.sanctorale).to be sanctorale
      end

      it 'preserves temporale settings' do
        factory = lambda do |year|
          CR::Temporale.new(year, transfer_to_sunday: [:epiphany])
        end

        cal = described_class.new(2016, nil, factory)
        new_cal = cal.pred

        # the transfer is preserved also in the new calendar
        d = new_cal.day(Date.new(2016, 1, 3))
        expect(d.celebrations[0].title).to have_translation 'The Epiphany of the Lord'
      end
    end

    describe '#succ' do
      it 'returns a calendar for the subsequent year' do
        new_cal = @c.succ
        expect(new_cal.year).to eq(@c.year + 1)
        expect(new_cal.sanctorale).to eq (@c.sanctorale)
      end

      it 'preserves sanctorale' do
        sanctorale = CR::Sanctorale.new
        cal = described_class.new(2000, sanctorale)
        new_cal = cal.succ
        expect(new_cal.sanctorale).to be sanctorale
      end

      it 'preserves temporale settings' do
        factory = lambda do |year|
          CR::Temporale.new(year, transfer_to_sunday: [:epiphany])
        end

        cal = described_class.new(2016, nil, factory)
        new_cal = cal.succ

        # the transfer is preserved also in the new calendar
        d = new_cal.day(Date.new(2018, 1, 7))
        expect(d.celebrations[0].title).to have_translation 'The Epiphany of the Lord'
      end
    end
  end
end
