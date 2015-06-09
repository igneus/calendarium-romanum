require 'date'

module CalendariumRomanum

  # calendar computations according to the Roman Catholic liturgical
  # calendar as instituted by 
  # MP Mysterii Paschalis of Paul VI. (AAS 61 (1969), pp. 222-226)
  class Calendar

    module Seasons
      ADVENT = :advent
      CHRISTMAS = :christmas
      LENT = :lent
      EASTER = :easter
      ORDINARY = :ordinary
      # is Triduum Sacrum a special season? For now I count Friday and Saturday
      # to the Lent, Sunday to the Easter time
    end

    include Seasons

    LECTIONARY_CYCLES = [:A, :B, :C]

    # year: Integer
    # returns a calendar for the liturgical year beginning with
    # Advent of the specified civil year.
    def initialize(year)
      @year = year
      @temporale = Temporale.new(year)
    end

    attr_reader :year

    def ==(obj)
      unless obj.is_a? Calendar
        return false
      end

      return year == obj.year
    end

    # DateTime of a year beginning
    # 00:00 of the first Advent Sunday
    def dt_beginning
      @temporale.advent_sunday(1).to_datetime
    end

    # DateTime of a year end
    # 23:59 of the last Saturday
    def dt_end
      day = @temporale.advent_sunday(1, @year+1) - 1
      return DateTime.new(day.year, day.month, day.day, 23, 59, 59)
    end

    def dt_range
      dt_beginning .. dt_end
    end

    # which liturgical season is it?
    def season(date)
      range_check date

      if @temporale.first_advent_sunday <= date and @temporale.nativity > date then
        Seasons::ADVENT

      elsif @temporale.nativity <= date and @temporale.baptism_of_lord >= date then
        Seasons::CHRISTMAS

      elsif @temporale.ash_wednesday <= date and @temporale.easter_sunday > date then
        Seasons::LENT

      elsif @temporale.easter_sunday <= date and @temporale.pentecost >= date then
        Seasons::EASTER

      else
        Seasons::ORDINARY
      end
    end

    def season_beginning(s)
      case s
      when Seasons::ADVENT
        @temporale.first_advent_sunday
      when Seasons::CHRISTMAS
        @temporale.nativity
      when Seasons::LENT
        @temporale.ash_wednesday
      when Seasons::EASTER
        @temporale.easter_sunday
      else
        @temporale.monday_after(@temporale.baptism_of_lord)
      end
    end

    # difference between two Dates in days
    def date_difference(d1, d2)
      return (d1 - d2).numerator
    end

    def season_week(seasonn, date)
      week1_beginning = season_beginning = season_beginning(seasonn)
      unless season_beginning.sunday?
        week1_beginning = @temporale.sunday_after(season_beginning)
      end

      week = date_difference(date, week1_beginning) / Temporale::WEEK + 1

      if seasonn == Seasons::ORDINARY
        # ordinary time does not begin with Sunday, but the first week
        # is week 1, not 0
        week += 1

        if date > @temporale.pentecost
          # gap made by Lent and Easter time
          week -= 12
        end
      end

      return week
    end
    
    # returns filled Day for the specified day
    def day(*args)
      date = self.class.mk_date *args
      range_check date

      s = season(date)
      return Day.new(
                     date: date,
                     season: s,
                     season_week: season_week(s, date)
                    )
    end

    # Sunday lectionary cycle
    def lectionary
      LECTIONARY_CYCLES[@year % 3]
    end

    # Ferial lectionary cycle
    def ferial_lectionary
      @year % 2 + 1
    end

    class << self
      # day(Date d)
      # day(Integer year, Integer month, Integer day)
      def day(*args)
        date = mk_date(*args)

        return for_day(date).day(date)
      end

      def mk_date(*args)
        ex = TypeError.new('Date, DateTime or three Integers expected')

        if args.size == 3 then
          args.each do |a| 
            unless a.is_a? Integer
              raise ex
            end
          end
          return Date.new *args

        elsif args.size == 1 then
          a = args.first
          unless a.is_a? Date or a.is_a? DateTime
            raise ex
          end
          return a

        else
          raise ex
        end
      end

      # creates a Calendar for the liturgical year including given
      # date
      def for_day(date)
        year = date.year
        temporale = Temporale.new year

        if date < temporale.first_advent_sunday
          return new(year - 1)
        end
        return new(year)
      end
    end # class << self

    private

    def range_check(date)
      unless dt_range.include? date
        raise RangeError.new "Date out of range #{date}"
      end
    end
  end # class Calendar
end
