require 'forwardable'

module CalendariumRomanum

  # Provides complete information concerning a liturgical year,
  # it's days and celebrations occurring on them.
  #
  # {Calendar}'s business logic is mostly about correctly combining
  # information from {Temporale} and {Sanctorale}.
  class Calendar
    extend Forwardable

    # Day when the implemented calendar system became effective
    EFFECTIVE_FROM = Date.new(1970, 1, 1).freeze

    # Returns a calendar for the liturgical year beginning with
    # Advent of the specified civil year.
    #
    # @overload initialize(year, sanctorale = nil, temporale = nil, vespers: false, transfers: nil)
    #   @param year [Integer]
    #     Civil year when the liturgical year begins.
    #   @param sanctorale [Sanctorale, nil]
    #     If not provided, the +Calendar+ will only know celebrations
    #     of the temporale cycle, no feasts of the saints!
    #   @param temporale [Temporale, nil]
    #     If not provided, +Temporale+ for the given year with default
    #     configuration will built.
    #   @param vespers [Boolean] Set to true if you want the +Calendar+ to populate {Day#vespers}
    #   @param transfers [#call, nil]
    #     Object with the same public interface as the +Transfers+ class (really class,
    #     not instance!), responsible for handling transfers of conflicting solemnities.
    #     Only useful for overriding the default solemnity transfer logic with a custom one.
    #
    # @overload initialize(temporale, sanctorale=nil, vespers: false, transfers: nil)
    #   @param temporale [Temporale]
    #   @param sanctorale [Sanctorale, nil]
    #   @param vespers [Boolean]
    #   @param transfers [#call, nil]
    #   @since 0.8.0
    #
    # @raise [RangeError]
    #   if +year+ is specified for which the implemented calendar
    #   system wasn't in force
    def initialize(year, sanctorale = nil, temporale = nil, vespers: false, transfers: nil, event_dispatcher: nil)
      unless year.is_a? Integer
        temporale = year
        year = temporale.year
      end

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

      @transferred = (transfers || Transfers).call(@temporale, @sanctorale).freeze

      @event_dispatcher = event_dispatcher || EventDispatcher.new
    end

    class << self
      # @api private
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

      # Creates a new instance for the liturgical year which includes
      # given date
      #
      # @param date [Date]
      # @param constructor_args
      #   arguments that will be passed to {initialize}
      # @return [Calendar]
      def for_day(date, *constructor_args)
        new(Temporale.liturgical_year(date), *constructor_args)
      end
    end # class << self

    # @!method range_check(date)
    #   @see Temporale#range_check
    #   @param date
    #   @return [void]
    # @!method season(date)
    #   @see Temporale#season
    #   @param date
    #   @return [Season]
    def_delegators :@temporale, :range_check, :season

    # @return [Integer]
    attr_reader :year

    # @return [Temporale]
    attr_reader :temporale

    # @return [Sanctorale]
    attr_reader :sanctorale

    # Solemnities transferred to a date different from the usual one
    # due to occurrence with a higher-ranking celebration.
    #
    # @return [Hash<Date=>Celebration>]
    # @since 0.8.0
    attr_reader :transferred

    # Do {Day} instances returned by this +Calendar+
    # have {Day#vespers} populated?
    # @return [Boolean]
    # @since 0.6.0
    def populates_vespers?
      @populate_vespers
    end

    # Two +Calendar+s are equal if they have equal settings
    # (which means that to equal input they return equal data)
    def ==(b)
      b.class == self.class &&
        year == b.year &&
        populates_vespers? == b.populates_vespers? &&
        temporale == b.temporale &&
        sanctorale == b.sanctorale
    end

    # Retrieve liturgical calendar information for the specified day
    # or range of days.
    #
    # @overload [](date)
    #   @param date [Date]
    #   @return [Day]
    # @overload [](range)
    #   @param range [Range<Date>]
    #   @return [Array<Day>]
    def [](args)
      if args.is_a?(Range)
        args.map {|date| day(date) }
      else
        day(args)
      end
    end

    # Retrieve liturgical calendar information for the specified day
    #
    # @overload day(date, vespers: false)
    #   @param date [Date]
    # @overload day(year, month, day, vespers: false)
    #   @param year [Integer]
    #   @param month [Integer]
    #   @param day [Integer]
    # @param vespers [Boolean]
    #   Set to +true+ in order to get {Day} with {Day#vespers}
    #   populated (overrides instance-wide setting {#populates_vespers?}).
    # @return [Day]
    # @raise [RangeError]
    #   If a date is specified on which the implemented calendar
    #   system was not yet in force (it became effective during
    #   the liturgical year 1969/1970)
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

    # Iterate over the whole liturgical year, day by day,
    # for each day yield calendar data.
    # If called without a block, returns +Enumerator+.
    #
    # @yield [Day]
    # @return [void, Enumerator]
    # @since 0.6.0
    def each
      return to_enum(__method__) unless block_given?

      temporale.date_range
        .each {|date| yield(day(date)) }
    end

    # Sunday lectionary cycle
    #
    # @return [Symbol]
    #   For possible values see {LECTIONARY_CYCLES}
    def lectionary
      LECTIONARY_CYCLES[@year % 3]
    end

    # Ferial lectionary cycle
    #
    # @return [1, 2]
    def ferial_lectionary
      @year % 2 + 1
    end

    # Freezes the instance.
    #
    # *WARNING*: {Temporale} and {Sanctorale} instances passed
    # to the +Calendar+ on initialization will be frozen, too!
    # This is necessary, because a +Calendar+ would not really be
    # frozen were it possible to mutate it's key components.
    def freeze
      @temporale.freeze
      @sanctorale.freeze
      super
    end

    private

    def celebrations_for(date)
      tr = transferred_on_event(date, @transferred[date]) if @transferred[date]
      return [tr] if tr

      t = temporale_retrieval_event date, @temporale[date]
      st = sanctorale_retrieval_event date, @sanctorale[date]

      if date.saturday? &&
         @temporale.season(date) == Seasons::ORDINARY &&
         (st.empty? || st.first.rank == Ranks::MEMORIAL_OPTIONAL) &&
         t.rank <= Ranks::MEMORIAL_OPTIONAL
        st += [Temporale::CelebrationFactory.saturday_memorial_bvm]
      end

      result =
      if st.empty?
        [t]
      else
        if st.first.rank > t.rank
          if st.first.rank == Ranks::MEMORIAL_OPTIONAL
            [t] + st
          else
            st
          end
        elsif t.rank == Ranks::FERIAL_PRIVILEGED && st.first.rank.memorial?
          commemorations = st.collect do |c|
            c.change(rank: Ranks::COMMEMORATION, colour: t.colour)
          end

          [t] + commemorations
        elsif t.symbol == :immaculate_heart &&
              [Ranks::MEMORIAL_GENERAL, Ranks::MEMORIAL_PROPER].include?(st.first.rank)
          optional_memorials = ([t] + st).collect do |celebration|
            celebration.change rank: Ranks::MEMORIAL_OPTIONAL
          end
          ferial = temporale.send :ferial, date # ugly and evil

          [ferial] + optional_memorials
        else
          [t]
        end
      end

      resolution_event date, result, t, st
    end

    def first_vespers_on(date, celebrations)
      tomorrow = date + 1
      tomorrow_celebrations = celebrations_for(tomorrow)

      c = tomorrow_celebrations.first

      result =
      if c.rank >= Ranks::SOLEMNITY_PROPER ||
         c.rank == Ranks::SUNDAY_UNPRIVILEGED ||
         (c.rank == Ranks::FEAST_LORD_GENERAL && tomorrow.sunday?)
        if c.symbol == :ash_wednesday || c.symbol == :good_friday
          nil
        elsif c.rank > celebrations.first.rank || c.symbol == :easter_sunday
          c
        else
          nil
        end
      end

      vespers_event date, result, celebrations, tomorrow_celebrations
    end

    # There is a solemnity transferred to the given date.
    # Listeners can prevent the transfer from taking effect
    # (and thus lose the solemnity for the given year) by setting
    # #celebration to nil, or even replace it with a completely
    # different celebration.
    class TransferredOnEvent < Struct.new(:date, :celebration, :calendar)
      EVENT_ID = :calendar__transferred_on
    end

    # Dispatched whenever {Calendar} retrieves {Celebration} for
    # a given date from {Temporale}.
    # Listeners can override the {Celebration}.
    class TemporaleRetrievalEvent < Struct.new(:date, :result, :calendar)
      EVENT_ID = :calendar__temporale_retrieval
    end

    # Dispatched whenever {Calendar} retrieves {Celebration}s for
    # a given date from {Sanctorale}.
    # Listeners can override the {Celebration}s.
    class SanctoraleRetrievalEvent < Struct.new(:date, :result, :calendar)
      EVENT_ID = :calendar__sanctorale_retrieval
    end

    # Dispatched whenever {Calendar} decides which {Celebration}(s)
    # will take place on the given date.
    # Listeners can replace the result.
    class TemporaleSanctoraleResolutionEvent < Struct.new(:date, :result, :temporale, :sanctorale, :calendar)
      EVENT_ID = :calendar__temporale_sanctorale_resolution
    end

    # Dispatched whenever {Calendar} decides which (if any)
    # {Celebration}'s Vespers should be celebrated on the given date.
    # Only valid options for +result+ are +nil+ (the day's {Celebration}
    # keeps the Vespers) or one of the {Celebration}s from +tomorrow+,
    # if it's rank makes it eligible for first Vespers.
    class VespersResolutionEvent < Struct.new(:date, :result, :today, :tomorrow, :calendar)
      EVENT_ID = :calendar__vespers_resolution
    end

    def transferred_on_event(*args)
      @event_dispatcher
        .dispatch(TransferredOnEvent.new(*args, self))
        .celebration
    end

    def temporale_retrieval_event(*args)
      @event_dispatcher
        .dispatch(TemporaleRetrievalEvent.new(*args, self))
        .result
    end

    def sanctorale_retrieval_event(*args)
      @event_dispatcher
        .dispatch(SanctoraleRetrievalEvent.new(*args, self))
        .result
    end

    def resolution_event(*args)
      @event_dispatcher
        .dispatch(TemporaleSanctoraleResolutionEvent.new(*args, self))
        .result
    end

    def vespers_event(*args)
      @event_dispatcher
        .dispatch(VespersResolutionEvent.new(*args, self))
        .result
    end

    def system_not_effective
      RangeError.new('Year out of range. Implemented calendar system has been in use only since 1st January 1970.')
    end
  end # class Calendar
end
