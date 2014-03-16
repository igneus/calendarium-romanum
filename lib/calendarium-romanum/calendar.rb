require 'date'

module CalendariumRomanum

  # calendar computations according to the Roman Catholic liturgical
  # calendar as instituted by 
  # MP Mysterii Paschalis of Paul VI. (AAS 61 (1969), pp. 222-226)
  class Calendar

    T_ADVENT = 'Advent'
    T_CHRISTMAS = 'Christmas Time'
    T_LENT = 'Lent'
    T_EASTER = 'Easter Time'
    T_ORDINARY = 'Ordinary Time'

    # year: Integer
    # returns a calendar for the liturgical year beginning with
    # Advent of the specified civil year.
    def initialize(year)
      @year = year
      @temporale = Temporale.new(year)
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

      if @temporale.advent_sunday(1) <= date and @temporale.nativity > date then
        return T_ADVENT

      elsif @temporale.nativity <= date and @temporale.baptism_of_lord >= date then
        return T_CHRISTMAS
      end
    end
    
    # returns filled Day for the specified day
    def day(*args)
      date = self.class.mk_date *args
      range_check date
    end

    class << self
      # day(Date d)
      # day(Integer year, Integer month, Integer day)
      def day(*args)
        date = mk_date(*args)

        return calendar_for_day(date).day(date)
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
      def calendar_for_day(date) 
      end
    end
  end

  private

  def range_check(date)
    unless dt_range.include? date
      raise ArgumentError("Date out of range #{date}")
    end
  end
end
