require_relative 'spec_helper'

describe CR::Calendar do
  before :all do
    @c = described_class.new(2013).freeze
  end

  let(:celfactory) { CR::Temporale::CelebrationFactory }

  describe '.new' do
    it 'throws RangeError on invalid year' do
      expect do
        described_class.new(1968)
      end.to raise_exception(RangeError, /in use only since 1st January 1970/)
    end

    it 'throws ArgumentError when Temporale year does not match' do
      year = 2000
      temporale = CR::Temporale.new year
      expect do
        CR::Calendar.new(year + 1, nil, temporale)
      end.to raise_exception ArgumentError
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

  describe '.each' do
    let (:day_count) {(@c.temporale.start_date..@c.temporale.end_date).count}

    it 'yields for each iteration' do
      expect { |b| @c.each(&b) }.to yield_control
    end

    it 'yields the expected number of times' do
      expect {|b| @c.each(&b) }.to yield_control.exactly(day_count).times
    end

    it 'yields calendar day instances' do
      expected_class = Array.new(day_count, CR::Day)
      expect {|b| @c.each(&b) }.to yield_successive_args(*expected_class)
    end
  end

  describe '#==' do
    let(:year) { 2014 }
    let(:b) { described_class.new(year) }

    describe 'year' do
      let(:a) { described_class.new(year) }

      it 'same' do
        expect(a).to be == described_class.new(year)
      end

      it 'different' do
        expect(a).not_to be == described_class.new(year + 1)
      end
    end

    describe 'sanctorale' do
      let(:sanctorale) { CR::Data::GENERAL_ROMAN_ENGLISH.load }
      let(:a) { described_class.new(year, sanctorale) }

      it 'same' do
        expect(a).to be == described_class.new(year, sanctorale)
      end

      it 'different' do
        expect(a == b).to be false
      end
    end

    describe 'temporale' do
      let(:temporale) { CR::Temporale.new year, transfer_to_sunday: [:epiphany] }
      let(:a) { described_class.new(year, nil, temporale) }

      it 'same' do
        expect(a).to be == described_class.new(year, nil, temporale)
      end

      it 'different' do
        expect(a).not_to be == b
      end
    end

    describe 'vespers' do
      let(:a) { described_class.new(year, vespers: true) }

      it 'same' do
        expect(a).to be == described_class.new(year, vespers: true)
      end

      it 'different' do
        expect(a == b).to be false
      end
    end
  end

  describe '#lectionary' do
    {
      2014 => :B,
      2013 => :A,
      2012 => :C
    }.each_pair do |year, cycle|
      it year.to_s do
        expect(described_class.new(year).lectionary).to eq cycle
      end
    end
  end

  describe '#ferial_lectionary' do
    {
      2014 => 1,
      2013 => 2
    }.each do |year, cycle|
      it year.to_s do
        expect(described_class.new(year).ferial_lectionary).to eq cycle
      end
    end
  end

  describe '#[]' do
    describe 'received arguments' do
      describe 'Date' do
        it 'returns a Day' do
          expect(@c[Date.new(2013, 12, 10)]).to be_a CR::Day
        end
      end

      describe 'Date range' do
        it 'returns an array of Days' do
          array = @c[Date.new(2013, 12, 10)..Date.new(2014, 4, 10)]
          expect(array).to be_a Array
          array.each{|day| expect(day).to be_a CR::Day}
        end
      end
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

    describe "date not included in the calendar's year" do
      it 'throws RangeError' do
        expect { @c.day(2000, 1, 1) }.to raise_exception RangeError
      end
    end

    describe 'date before system effectiveness' do
      it 'throws RangeError' do
        c = described_class.new 1969
        expect { c.day(1969, 12, 20) }.to raise_exception RangeError
      end
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

              describe 'second last' do
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
        expect(celebs[0]).to eq celfactory.good_friday

        # it is transferred on a day after the Easter octave
        d = c.temporale.easter_sunday + 8
        celebs = c.day(d).celebrations
        expect(celebs.size).to eq 1
        expect(celebs[0].title).to eq 'Annunciation of the Lord'
      end

      describe 'collision of Immaculate Heart with another obligatory memorial' do
        let(:year) { 2002 }
        let(:c) { described_class.new year, @s }
        let(:date) { Date.new(2003, 6, 28) }

        it 'makes both optional memorials' do
          # make sure
          expect(c.sanctorale.get(date).first.rank).to eq CR::Ranks::MEMORIAL_GENERAL
          expect(c.temporale.get(date).rank).to eq CR::Ranks::MEMORIAL_GENERAL

          celebrations = c.day(date).celebrations
          expect(celebrations.size).to eq 3

          expect(celebrations[0].rank).to eq CR::Ranks::FERIAL
          expect(celebrations[1..-1].collect(&:rank).uniq)
            .to eq([CR::Ranks::MEMORIAL_OPTIONAL])
        end
      end
    end

    describe 'Saturday memorial' do
      let(:sanctorale) { double(CR::Sanctorale, solemnities: {}) }
      let(:calendar) { described_class.new(2013, sanctorale) }
      let(:celebrations) { calendar.day(date).celebrations }

      describe 'free Saturday in Ordinary Time' do
        let(:date) { Date.new(2014, 8, 16) }

        before :each do
          allow(sanctorale).to receive(:[]).and_return([])
        end

        it 'offers Saturday memorial' do
          expect(celebrations.find {|c| c.symbol == :saturday_memorial_bvm}).not_to be nil
        end

        it 'properly translates the title' do
          saturday_memorial = celebrations.find {|c| c.symbol == :saturday_memorial_bvm}
          expect(saturday_memorial.title).to have_translation 'Saturday Memorial of the Blessed Virgin Mary'
        end
      end

      describe 'Saturday in Ordinary Time with optional memorial(s)' do
        let(:date) { Date.new(2014, 8, 23) }

        before :each do
          memorial = CR::Celebration.new('', CR::Ranks::MEMORIAL_OPTIONAL)
          allow(sanctorale).to receive(:[]).and_return([memorial])
        end

        it 'offers Saturday memorial' do
          expect(celebrations.find {|c| c.symbol == :saturday_memorial_bvm}).not_to be nil
        end
      end

      describe 'non-free Saturday in Ordinary Time' do
        let(:date) { Date.new(2014, 9, 13) }

        before :each do
          memorial = CR::Celebration.new('', CR::Ranks::MEMORIAL_GENERAL)
          allow(sanctorale).to receive(:[]).and_return([memorial])
        end

        it 'does not offer Saturday memorial' do
          expect(celebrations.find {|c| c.symbol == :saturday_memorial_bvm}).to be nil
        end
      end

      describe 'free Saturday in another season' do
        let(:date) { Date.new(2013, 12, 14) }

        before :each do
          allow(sanctorale).to receive(:[]).and_return([])
        end

        it 'does not offer Saturday memorial' do
          expect(celebrations.find {|c| c.symbol == :saturday_memorial_bvm}).to be nil
        end
      end
    end

    describe 'Vespers' do
      let(:saturday) { Date.new(2014, 1, 4) }
      let(:year) { 2013 }
      let(:calendar) { described_class.new(year) }

      describe 'not opted in' do
        it 'does not fill Vespers' do
          day = calendar.day saturday
          expect(day.vespers).to be nil
        end
      end

      describe 'opted in by constructor argument' do
        let(:calendar) { described_class.new(year, nil, nil, vespers: true) }

        it 'fills Vespers' do
          day = calendar.day saturday
          expect(day.vespers).to be_a CR::Celebration
        end

        describe 'but the day has not Vespers from following' do
          it 'does not fill Vespers' do
            friday = saturday - 1
            day = calendar.day friday
            expect(day.vespers).to be nil
          end
        end
      end

      describe 'opted in by argument' do
        it 'fills Vespers' do
          day = calendar.day saturday, vespers: true
          expect(day.vespers).to be_a CR::Celebration
        end
      end

      describe 'first Vespers of' do
        let(:sanctorale) { CR::Data::GENERAL_ROMAN_ENGLISH.load }
        let(:calendar) { described_class.new(year, sanctorale, nil, vespers: true) }

        describe 'a Sunday' do
          it 'has first Vespers' do
            day = calendar.day saturday
            expect(day.vespers.rank).to eq CR::Ranks::SUNDAY_UNPRIVILEGED
          end
        end

        describe 'a solemnity' do
          let(:testing_solemnity) do
            CR::Celebration.new(
              'Testing solemnity',
              CR::Ranks::SOLEMNITY_GENERAL,
              CR::Colours::WHITE,
              :test
            )
          end

          it 'has first Vespers' do
            day = calendar.day(Date.new(2014, 11, 1) - 1)
            expect(day.vespers.rank).to be CR::Ranks::SOLEMNITY_GENERAL
          end

          describe 'clash with Sunday Vespers' do
            it 'wins over Sunday' do
              sunday = Date.new(2014, 8, 17)
              expect(sunday).to be_sunday # make sure
              sanctorale.replace(8, 17, [testing_solemnity])

              day = calendar.day(sunday - 1)
              expect(day.vespers.symbol).to eq :test
            end
          end

          describe 'clash with second Vespers of another solemnity' do
            it "the day's Vespers win" do
              assumption = Date.new(2014, 8, 15)
              sanctorale.replace(8, 16, [testing_solemnity])

              day = calendar.day(assumption)
              expect(day.celebrations.first.rank).to be CR::Ranks::SOLEMNITY_GENERAL
              expect(day.vespers).to be nil

              # make sure
              next_day = calendar.day(assumption + 1)
              expect(next_day.celebrations.first).to be testing_solemnity
            end
          end
        end

        describe 'feast of the Lord' do
          describe 'not falling on a Sunday' do
            it 'does not have first Vespers' do
              calendar = described_class.new(2015, sanctorale, nil, vespers: true)
              presentation = Date.new(2016, 2, 2)
              expect(presentation).not_to be_sunday # make sure

              day = calendar.day(presentation - 1)
              expect(day.vespers).to be nil
            end
          end

          describe 'falling on a Sunday' do
            it 'has first Vespers' do
              presentation = Date.new(2014, 2, 2)
              expect(presentation).to be_sunday # make sure

              day = calendar.day(presentation - 1)
              expect(day.vespers.rank).to be CR::Ranks::FEAST_LORD_GENERAL
            end
          end
        end

        # this group contains both days having and days not having
        # first Vespers: special care must be taken
        describe 'primary liturgical days' do
          describe 'Ash Wednesday' do
            it 'does not have first Vespers' do
              aw = CR::Temporale::Dates.ash_wednesday year
              day = calendar.day(aw - 1)
              expect(day.vespers).to be nil
            end
          end

          describe 'Nativity' do
            it 'has first Vespers' do
              day = calendar.day Date.new(2013, 12, 24)
              expect(day.vespers).to eq celfactory.nativity
            end
          end

          describe 'Epiphany' do
            it 'has first Vespers' do
              day = calendar.day Date.new(2014, 1, 5)
              expect(day.vespers.rank).to be CR::Ranks::PRIMARY
              expect(day.vespers.symbol).to be :epiphany
            end
          end

          describe 'Palm Sunday' do
            it 'has first Vespers' do
              ps = CR::Temporale::Dates.palm_sunday year
              day = calendar.day(ps - 1)
              expect(day.vespers).to eq celfactory.palm_sunday
            end
          end

          describe 'day in the Holy week' do
            it 'does not have first Vespers' do
              tuesday = CR::Temporale::Dates.palm_sunday(year) + 2
              day = calendar.day(tuesday - 1)
              expect(day.vespers).to be nil
            end
          end

          describe 'Good Friday' do
            it 'does not have first Vespers' do
              gf = CR::Temporale::Dates.good_friday(year)
              day = calendar.day(gf - 1)
              expect(day.vespers).to be nil
            end
          end

          describe 'Easter' do
            it 'has first Vespers' do
              es = CR::Temporale::Dates.easter_sunday year
              day = calendar.day(es - 1)
              expect(day.vespers).to eq celfactory.easter_sunday
            end
          end

          describe 'day in Easter octave' do
            it 'does not have first Vespers' do
              tuesday = CR::Temporale::Dates.easter_sunday(year) + 2
              day = calendar.day(tuesday - 1)
              expect(day.vespers).to be nil
            end
          end
        end

        describe 'edge cases' do
          describe 'First Sunday of Advent' do
            it 'has first Vespers (and does not cause an exception)' do
              sunday = CR::Temporale::Dates.first_advent_sunday(year + 1)
              day = calendar.day(sunday - 1)
              expect(day.vespers).to eq celfactory.first_advent_sunday
            end
          end
        end
      end
    end
  end
end
