require 'date'
require 'forwardable'

module CalendariumRomanum

  # Provides complete information concerning a liturgical year,
  # it's days and celebrations occurring on them.
  class Calendar

    extend Forwardable

    # year: Integer
    # returns a calendar for the liturgical year beginning with
    # Advent of the specified civil year.
    def initialize(year, sanctorale=nil)
      @year = year
      @temporale = Temporale.new(year)
      @sanctorale = sanctorale || Sanctorale.new
      @transferred = Transfers.new(@temporale, @sanctorale)
    end

    class << self
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
          unless a.is_a? Date
            raise ex
          end
          return a

        else
          raise ex
        end
      end

      # creates a Calendar for the liturgical year including given
      # date
      def for_day(date, sanctorale=nil)
        return new(Temporale.liturgical_year(date), sanctorale)
      end
    end # class << self

    def_delegators :@temporale, :range_check, :season
    attr_reader :year
    attr_reader :temporale
    attr_reader :sanctorale

    # returns a Calendar for the subsequent year
    def succ
      c = Calendar.new @year + 1, @sanctorale
      return c
    end

    # returns a Calendar for the previous year
    def pred
      c = Calendar.new @year - 1, @sanctorale
      return c
    end

    def ==(obj)
      unless obj.is_a? Calendar
        return false
      end

      return year == obj.year
    end

    # accepts date information represented as
    # Date, DateTime, or two to three integers
    # (month - day or year - month - day);
    # returns filled Day for the specified day
    def day(*args)
      if args.size == 2
        date = Date.new(@year, *args)
        unless @temporale.date_range.include? date
          date = Date.new(@year + 1, *args)
        end
      else
        date = self.class.mk_date *args
        range_check date
      end

      s = @temporale.season(date)
      return Day.new(
                     date: date,
                     season: s,
                     season_week: @temporale.season_week(s, date),
                     celebrations: celebrations_for(date)
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

    def celebrations_for(date)
      tr = @transferred.get(date)
      return [tr] if tr

      t = @temporale.get date
      st = @sanctorale.get date

      unless st.empty?
        if st.first.rank > t.rank
          if st.first.rank == Ranks::MEMORIAL_OPTIONAL
            st.unshift t
            return st
          else
            return st
          end
        elsif t.rank == Ranks::FERIAL_PRIVILEGED && st.first.rank.memorial?
          st = st.collect do |c|
            Celebration.new(c.title, Ranks::COMMEMORATION, t.colour)
          end
          st.unshift t
          return st
        end
      end

      return [t]
    end
  end # class Calendar
end
