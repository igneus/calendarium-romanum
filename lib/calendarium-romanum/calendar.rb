require 'date'

module CalendariumRomanum

  # calendar computations according to the Roman Catholic liturgical
  # calendar as instituted by 
  # MP Mysterii Paschalis of Paul VI. (AAS 61 (1969), pp. 222-226)
  class Calendar

    extend Forwardable
    def_delegators :@temporale, :range_check

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
    
    # returns filled Day for the specified day
    def day(*args)
      date = self.class.mk_date *args
      range_check date

      s = @temporale.season(date)
      return Day.new(
                     date: date,
                     season: s,
                     season_week: @temporale.season_week(s, date)
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
  end # class Calendar
end
