require_relative 'spec_helper'

describe CR::Temporale do

  before :all do
    @t = @t12 = described_class.new 2012
    @t13 = described_class.new 2013
  end

  describe '.liturgical_year' do
    it 'returns liturgical year for the given date' do
      [
        [Date.new(2014, 11, 1), 2013],
        [Date.new(2014, 12, 1), 2014]
      ].each do |date, year|
        described_class.liturgical_year(date).should eq year
      end
    end
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

  describe '#date_range' do
    it 'includes days of the year' do
      @t.date_range.should include Date.new(2012, 12, 3)
      @t.date_range.should include Date.new(2013, 11, 5)
    end
  end

  describe '#season' do
    it 'determines Advent' do
      @t13.season(Date.new(2013, 12, 15)).should eq CR::Seasons::ADVENT
      @t13.season(Date.new(2013, 12, 1)).should eq CR::Seasons::ADVENT
      @t13.season(Date.new(2013, 12, 24)).should eq CR::Seasons::ADVENT
    end

    it 'determines Christmas' do
      @t13.season(Date.new(2013, 12, 25)).should eq CR::Seasons::CHRISTMAS
      @t13.season(Date.new(2014, 1, 12)).should eq CR::Seasons::CHRISTMAS
      @t13.season(Date.new(2014, 1, 13)).should eq CR::Seasons::ORDINARY
    end

    it 'determines Lent' do
      @t13.season(Date.new(2014, 3, 4)).should eq CR::Seasons::ORDINARY
      @t13.season(Date.new(2014, 3, 5)).should eq CR::Seasons::LENT
      @t13.season(Date.new(2014, 4, 19)).should eq CR::Seasons::LENT
      @t13.season(Date.new(2014, 4, 20)).should eq CR::Seasons::EASTER
    end

    it 'determines Easter time' do
      @t13.season(Date.new(2014, 4, 20)).should eq CR::Seasons::EASTER
      @t13.season(Date.new(2014, 6, 8)).should eq CR::Seasons::EASTER
      @t13.season(Date.new(2014, 6, 9)).should eq CR::Seasons::ORDINARY
    end
  end

  describe '#get' do
    it 'returns a Celebration' do
      expect(@t13.get(8, 12)).to be_a CR::Celebration
    end

    describe 'for' do
      describe 'ferial' do
        it 'in Ordinary Time' do
          c = @t13.get(8, 12)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::GREEN
        end

        it 'in Advent' do
          c = @t13.get(12, 12)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in the last week of Advent' do
          c = @t13.get(12, 23)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Christmas time' do
          c = @t13.get(1, 3)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::WHITE
        end

        it 'in Lent' do
          c = @t13.get(3, 18)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Easter Time' do
          c = @t13.get(5, 5)
          expect(c.rank).to eq CR::Ranks::FERIAL
          expect(c.color).to eq CR::Colours::WHITE
        end
      end

      describe 'Sunday' do
        it 'in Ordinary Time' do
          c = @t13.get(8, 10)
          expect(c.rank).to eq CR::Ranks::SUNDAY_UNPRIVILEGED
          expect(c.color).to eq CR::Colours::GREEN
        end

        it 'in Advent' do
          c = @t13.get(12, 15)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Christmas time' do
          c = @t13.get(1, 5)
          expect(c.rank).to eq CR::Ranks::SUNDAY_UNPRIVILEGED
          expect(c.color).to eq CR::Colours::WHITE
        end

        it 'in Lent' do
          c = @t13.get(3, 23)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.color).to eq CR::Colours::VIOLET
        end

        it 'in Easter Time' do
          c = @t13.get(5, 11)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.color).to eq CR::Colours::WHITE
        end
      end

      describe 'solemnities and their cycles - ' do
        it 'end of Advent time' do
          c = @t13.get(12, 17)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.colour).to eq CR::Colours::VIOLET
        end

        it 'Nativity' do
          c = @t13.get(12, 25)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to eq 'The Nativity of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'day in the octave of Nativity' do
          c = @t13.get(12, 27)
          expect(c.rank).to eq CR::Ranks::FERIAL_PRIVILEGED
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Holy Family' do
          c = @t13.get(12, 29)
          expect(c.rank).to eq CR::Ranks::FEAST_LORD_GENERAL
          expect(c.title).to eq 'The Holy Family of Jesus, Mary and Joseph'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        context 'when a Sunday does not occur between Dec 25 and Jan 1' do
          it 'is Holy Family on Friday Dec 30' do
            @t16 = described_class.new 2016
            c = @t16.get(12, 30)
            expect(c.title).to eq 'The Holy Family of Jesus, Mary and Joseph'
          end
        end

        it 'Epiphany' do
          c = @t13.get(1, 6)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to eq 'The Epiphany of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Baptism of the Lord' do
          c = @t13.get(1, 12)
          expect(c.rank).to eq CR::Ranks::FEAST_LORD_GENERAL
          expect(c.title).to eq 'The Baptism of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Ash Wednesday' do
          c = @t13.get(3, 5)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to eq 'Ash Wednesday'
          expect(c.colour).to eq CR::Colours::VIOLET
        end

        it 'Palm Sunday' do
          c = @t13.get(4, 13)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to eq 'Palm Sunday of the Passion of the Lord'
          expect(c.colour).to eq CR::Colours::RED
        end

        it 'Good Friday' do
          c = @t13.get(4, 18)
          expect(c.rank).to eq CR::Ranks::TRIDUUM
          expect(c.title).to eq 'Friday of the Passion of the Lord'
          expect(c.colour).to eq CR::Colours::RED
        end

        it 'Holy Saturday' do
          c = @t13.get(4, 19)
          expect(c.rank).to eq CR::Ranks::TRIDUUM
          expect(c.title).to eq 'Holy Saturday'
          expect(c.colour).to eq CR::Colours::VIOLET
        end

        it 'Resurrection' do
          c = @t13.get(4, 20)
          expect(c.rank).to eq CR::Ranks::TRIDUUM
          expect(c.title).to eq 'Easter Sunday of the Resurrection of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'day in the Easter Octave' do
          c = @t13.get(4, 22)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Ascension' do
          c = @t13.get(5, 29)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to eq 'Ascension of the Lord'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Pentecost' do
          c = @t13.get(6, 8)
          expect(c.rank).to eq CR::Ranks::PRIMARY
          expect(c.title).to eq 'Pentecost Sunday'
          expect(c.colour).to eq CR::Colours::RED
        end

        it 'Trinity' do
          c = @t13.get(6, 15)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to eq 'The Most Holy Trinity'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Body of Christ' do
          c = @t13.get(6, 19)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to eq 'The Most Holy Body and Blood of Christ'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Sacred Heart' do
          c = @t13.get(6, 27)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to eq 'The Most Sacred Heart of Jesus'
          expect(c.colour).to eq CR::Colours::WHITE
        end

        it 'Christ the King' do
          c = @t13.get(11, 23)
          expect(c.rank).to eq CR::Ranks::SOLEMNITY_GENERAL
          expect(c.title).to eq 'Our Lord Jesus Christ, King of the Universe'
          expect(c.colour).to eq CR::Colours::WHITE
        end
      end
    end
  end

  describe 'initialized without a year' do
    before :each do
      @tny = described_class.new
    end

    it 'is possible to initialize a Temporale without a year' do
      expect { described_class.new }.not_to raise_exception
    end

    it 'crashes when a date is requested without year' do
      expect { @tny.first_advent_sunday }.to raise_exception
    end

    it 'computes dates as expected if year is given' do
      days = %i(first_advent_sunday nativity holy_family mother_of_god
      epiphany baptism_of_lord ash_wednesday easter_sunday good_friday
      holy_saturday pentecost
      holy_trinity body_blood sacred_heart christ_king

      date_range)
      days.each do |msg|
        @tny.send(msg, 2012).should eq @t12.send(msg)
      end
    end

    describe '#get' do
      it 'always raises an exception' do
        # for get to work well is imoportant to have precomputed
        # solemnity dates. That is only possible when a year
        # is specified on initialization.
        [
          Date.new(2015, 1, 1),
          Date.new(2015, 9, 23),
          Date.new(2015, 3, 4)
        ].each do |date|
          expect { @tny.get(date) }.to raise_exception
        end
      end
    end
  end
end
