require 'date'
require 'forwardable'

module CalendariumRomanum

  # Provides complete information concerning a liturgical year,
  # it's days and celebrations occurring on them.
  class Calendar
    extend Forwardable

    # Day when the implemented calendar system became effective
    EFFECTIVE_FROM = Date.new(1970, 1, 1).freeze

    # year: Integer
    # returns a calendar for the liturgical year beginning with
    # Advent of the specified civil year.
    def initialize(year, sanctorale = nil, temporale = nil, vespers: false)
      if year < (EFFECTIVE_FROM.year - 1)
        raise system_not_effective
      end

      if temporale && temporale.year != year
        raise ArgumentError.new('Temporale year must be the same as year.')
      end

      @year = year
      @sanctorale = sanctorale || Sanctorale.new
      @temporale = temporale || Temporale.new(year)
      @populate_vespers = vespers

      @transferred = Transfers.new(@temporale, @sanctorale)
    end

    class << self
      def mk_date(*args)
        ex = TypeError.new('Date, DateTime or three Integers expected')

        if args.size == 3
          args.each do |a|
            raise ex unless a.is_a? Integer
          end
          return Date.new(*args)

        elsif args.size == 1
          a = args.first
          raise ex unless a.is_a? Date
          return a

        else
          raise ex
        end
      end

      # creates a Calendar for the liturgical year including given
      # date
      def for_day(date, *constructor_args)
        new(Temporale.liturgical_year(date), *constructor_args)
      end
    end # class << self

    def_delegators :@temporale, :range_check, :season
    attr_reader :year
    attr_reader :temporale
    attr_reader :sanctorale

    def populates_vespers?
      @populate_vespers
    end

    # Calendars are equal if they have equal settings
    # (which means that to equal input they return equal data)
    def ==(b)
      b.class == self.class &&
        year == b.year &&
        populates_vespers? == b.populates_vespers? &&
        temporale == b.temporale &&
        sanctorale == b.sanctorale
    end

    def [](args)
      if(args.is_a?(Range))
        args.map{|date| day(date)}
      else
        day(args)
      end
    end

    # accepts date information represented as
    # Date, DateTime, or two to three integers
    # (month - day or year - month - day);
    # returns filled Day for the specified day
    def day(*args, vespers: false)
      if args.size == 2
        date = Date.new(@year, *args)
        unless @temporale.date_range.include? date
          date = Date.new(@year + 1, *args)
        end
      else
        date = self.class.mk_date(*args)
        range_check date
      end

      if date < EFFECTIVE_FROM
        raise system_not_effective
      end

      celebrations = celebrations_for(date)
      vespers_celebration = nil
      if @populate_vespers || vespers
        begin
          vespers_celebration = first_vespers_on(date, celebrations)
        rescue RangeError
          # there is exactly one possible case when
          # range_check(date) passes and range_check(date + 1) fails:
          vespers_celebration = Temporale::CelebrationFactory.first_advent_sunday
        end
      end

      s = @temporale.season(date)
      Day.new(
        date: date,
        season: s,
        season_week: @temporale.season_week(s, date),
        celebrations: celebrations,
        vespers: vespers_celebration
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

    def freeze
      @temporale.freeze
      @sanctorale.freeze
      super
    end

    private

    def celebrations_for(date)
      tr = @transferred.get(date)
      return [tr] if tr

      t = @temporale[date]
      st = @sanctorale[date]

      unless st.empty?
        if st.first.rank > t.rank
          if st.first.rank == Ranks::MEMORIAL_OPTIONAL
            return st.dup.unshift t
          else
            return st
          end
        elsif t.rank == Ranks::FERIAL_PRIVILEGED && st.first.rank.memorial?
          st = st.collect do |c|
            Celebration.new(c.title, Ranks::COMMEMORATION, t.colour)
          end
          st.unshift t
          return st
        elsif t.symbol == :immaculate_heart &&
              [Ranks::MEMORIAL_GENERAL, Ranks::MEMORIAL_PROPER].include?(st.first.rank)
          optional_memorials = ([t] + st).collect do |celebration|
            celebration.change rank: Ranks::MEMORIAL_OPTIONAL
          end
          ferial = temporale.send :ferial, date # ugly and evil
          return [ferial] + optional_memorials
        end
      end

      [t]
    end

    def first_vespers_on(date, celebrations)
      tomorrow = date + 1
      tomorrow_celebrations = celebrations_for(tomorrow)

      c = tomorrow_celebrations.first
      if c.rank >= Ranks::SOLEMNITY_PROPER ||
         c.rank == Ranks::SUNDAY_UNPRIVILEGED ||
         (c.rank == Ranks::FEAST_LORD_GENERAL && tomorrow.sunday?)
        if c.symbol == :ash_wednesday || c.symbol == :good_friday
          return nil
        end

        if c.rank > celebrations.first.rank || c.symbol == :easter_sunday
          return c
        end
      end

      nil
    end

    def system_not_effective
      RangeError.new('Year out of range. Implemented calendar system has been in use only since 1st January 1970.')
    end
  end # class Calendar
end
