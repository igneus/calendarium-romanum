module CalendariumRomanum

  # One of the two main {Calendar} components.
  # Handles seasons and celebrations of the temporale cycle
  # for a given liturgical year.
  class Temporale

    # How many days in a week
    WEEK = 7

    # Which solemnities can be transferred to Sunday
    SUNDAY_TRANSFERABLE_SOLEMNITIES =
      %i(epiphany ascension corpus_christi).freeze

    # @param year [Integer]
    #   the civil year when the liturgical year _begins_
    # @param extensions [Array<#each_celebration>]
    #   extensions implementing custom temporale celebrations
    # @param transfer_to_sunday [Array<Symbol>]
    #   which solemnities should be transferred to a nearby
    #   Sunday - see {SUNDAY_TRANSFERABLE_SOLEMNITIES}
    #   for possible values
    def initialize(year, extensions: [], transfer_to_sunday: [])
      @year = year

      @extensions = extensions
      @transfer_to_sunday = transfer_to_sunday.sort
      validate_sunday_transfer!

      prepare_solemnities
    end

    # @return [Integer]
    attr_reader :year

    # @return [Array<Symbol>]
    attr_reader :transfer_to_sunday

    # @return [Array<#each_celebration>]
    attr_reader :extensions

    class << self
      # Determines liturgical year for the given date
      #
      # @param date [Date]
      # @return [Integer]
      def liturgical_year(date)
        year = date.year

        if date < Dates.first_advent_sunday(year)
          return year - 1
        end

        year
      end

      # Creates an instance for the liturgical year including given
      # date
      #
      # @param date [Date]
      # @return [Temporale]
      def for_day(date)
        new(liturgical_year(date))
      end

      # Factory method creating temporale {Celebration}s
      # with sensible defaults
      #
      # See {Celebration#initialize} for argument description.
      def create_celebration(title, rank, colour, symbol: nil, date: nil, sunday: nil)
        Celebration.new(
          title: title,
          rank: rank,
          colour: colour,
          symbol: symbol,
          date: date,
          cycle: :temporale,
          sunday: sunday
        )
      end

      C = Struct.new(:date_method, :celebration)
      private_constant :C

      # @api private
      def celebrations
        @celebrations ||=
          begin
            %i(
              nativity
              holy_family
              mother_of_god
              epiphany
              baptism_of_lord
              ash_wednesday
              good_friday
              holy_saturday
              palm_sunday
              easter_sunday
              ascension
              pentecost
              holy_trinity
              corpus_christi
              mother_of_church
              sacred_heart
              christ_king
              immaculate_heart
            ).collect do |symbol|
              date_method = symbol
              C.new(
                date_method,
                CelebrationFactory.public_send(symbol)
              )
            end
            # Immaculate Heart of Mary and Mary, Mother of the Church
            # are actually movable *sanctorale* feasts,
            # but as it would make little sense
            # to add support for movable sanctorale feasts because of
            # two, we cheat a bit and handle them in temporale.
          end
      end
    end

    # Does this instance transfer the specified solemnity to Sunday?
    #
    # @param solemnity [Symbol]
    # @return [Boolean]
    def transferred_to_sunday?(solemnity)
      @transfer_to_sunday.include?(solemnity)
    end

    # First day of the liturgical year
    #
    # @return [Date]
    def start_date
      first_advent_sunday
    end

    # Last day of the liturgical year
    #
    # @return [Date]
    def end_date
      Dates.first_advent_sunday(year + 1) - 1
    end

    # Date range of the liturgical year
    #
    # @return [Range<Date>]
    def date_range
      start_date .. end_date
    end

    # Check that the date belongs to the liturgical year.
    # If it does not, throw exception.
    #
    # @param date [Date]
    # @return [void]
    # @raise [RangeError]
    def range_check(date)
      # necessary in order to handle Date correctly
      date = date.to_date if date.class != Date

      unless date_range.include? date
        raise RangeError.new "Date out of range #{date}"
      end
    end

    # @!method nativity
    #   @return [Date]
    # @!method holy_family
    #   @return [Date]
    # @!method mother_of_god
    #   @return [Date]
    # @!method epiphany
    #   @return [Date]
    # @!method baptism_of_lord
    #   @return [Date]
    # @!method ash_wednesday
    #   @return [Date]
    # @!method good_friday
    #   @return [Date]
    # @!method holy_saturday
    #   @return [Date]
    # @!method palm_sunday
    #   @return [Date]
    # @!method easter_sunday
    #   @return [Date]
    # @!method ascension
    #   @return [Date]
    # @!method pentecost
    #   @return [Date]
    # @!method holy_trinity
    #   @return [Date]
    # @!method corpus_christi
    #   @return [Date]
    # @!method mother_of_church
    #   @return [Date]
    # @!method sacred_heart
    #   @return [Date]
    # @!method christ_king
    #   @return [Date]
    # @!method immaculate_heart
    #   @return [Date]
    # @!method first_advent_sunday
    #   @return [Date]
    (celebrations.collect(&:date_method) + [:first_advent_sunday])
      .each do |feast|
      if SUNDAY_TRANSFERABLE_SOLEMNITIES.include? feast
        define_method feast do
          Dates.public_send feast, year, sunday: transferred_to_sunday?(feast)
        end
      elsif feast == :baptism_of_lord
        define_method feast do
          Dates.public_send feast, year, epiphany_on_sunday: transferred_to_sunday?(:epiphany)
        end
      else
        define_method feast do
          Dates.public_send feast, year
        end
      end
    end

    # Determine liturgical season for a given date
    #
    # @param date [Date]
    # @return [Season]
    # @raise [RangeError]
    #   if the given date doesn't belong to the liturgical year
    def season(date)
      range_check date

      if first_advent_sunday <= date &&
         nativity > date
        Seasons::ADVENT

      elsif nativity <= date &&
            baptism_of_lord >= date
        Seasons::CHRISTMAS

      elsif ash_wednesday <= date &&
            good_friday > date
        Seasons::LENT

      elsif good_friday <= date &&
            easter_sunday >= date
        Seasons::TRIDUUM

      elsif easter_sunday < date &&
            pentecost >= date
        Seasons::EASTER

      else
        Seasons::ORDINARY
      end
    end

    # When the specified liturgical season begins
    #
    # @param s [Season]
    # @return [Date]
    def season_beginning(s)
      case s
      when Seasons::ADVENT
        first_advent_sunday
      when Seasons::CHRISTMAS
        nativity
      when Seasons::LENT
        ash_wednesday
      when Seasons::TRIDUUM
        good_friday
      when Seasons::EASTER
        easter_sunday + 1
      when Seasons::ORDINARY
        baptism_of_lord + 1
      else
        raise ArgumentError.new('unsupported season')
      end
    end

    # Determine week of a season for a given date
    #
    # @param seasonn [Season]
    # @param date [Date]
    def season_week(seasonn, date)
      week1_beginning = season_beginning = season_beginning(seasonn)
      unless season_beginning.sunday?
        week1_beginning = Dates.sunday_after(season_beginning)
      end

      week = date_difference(date, week1_beginning) / WEEK + 1

      if seasonn == Seasons::ORDINARY || seasonn == Seasons::EASTER
        # ordinary time does not begin with Sunday, but the first week
        # is week 1, not 0
        week += 1
      end

      if seasonn == Seasons::ORDINARY
        if date > pentecost
          weeks_after_date = date_difference(Dates.first_advent_sunday(@year + 1), date) / WEEK
          week = 34 - weeks_after_date
          week += 1 if date.sunday?
        end
      end

      week
    end

    # Retrieve temporale celebration for the given day
    #
    # @param date [Date]
    # @return [Celebration]
    # @since 0.6.0
    def [](date)
      sw = season_and_week(date)

      @solemnities[date] || @feasts[date] || sunday(date, sw) || @memorials[date] || ferial(date, sw)
    end

    # Retrieve temporale celebration for the given day
    #
    # @overload get(date)
    #   @param date [Date]
    # @overload get(month, day)
    #   @param month [Integer]
    #   @param day [Integer]
    # @return (see #[])
    def get(*args)
      if args.size == 1 && args[0].is_a?(Date)
        date = args[0]
      else
        month, day = args
        date = Date.new @year, month, day
        unless date_range.include? date
          date = Date.new @year + 1, month, day
        end
      end

      self[date]
    end

    # Enumerates dates and celebrations
    #
    # @yield [Date, Celebration]
    # @return [void, Enumerator] if called without a block, returns +Enumerator+
    # @since 0.8.0
    def each_day
      return to_enum(__method__) unless block_given?

      date_range.each {|date| yield date, self[date] }
    end

    # @return [Boolean]
    # @since 0.6.0
    def ==(b)
      self.class == b.class &&
        year == b.year &&
        transfer_to_sunday == b.transfer_to_sunday &&
        Set.new(extensions) == Set.new(b.extensions)
    end

    # Does this instance provide celebration identified by symbol +symbol+?
    #
    # @param symbol [Symbol]
    # @return [Boolean]
    def provides_celebration?(symbol)
      @all_celebration_symbols.include? symbol
    end

    private

    SeasonWeek = Struct.new(:season, :week)
    private_constant :SeasonWeek

    def season_and_week(date)
      s = season(date)
      w = season_week(s, date)

      SeasonWeek.new(s, w)
    end

    # seasons when Sundays have higher rank
    SEASONS_SUNDAY_PRIMARY = [Seasons::ADVENT, Seasons::LENT, Seasons::EASTER].freeze

    def sunday(date, season_week)
      return nil unless date.sunday?

      rank = Ranks::SUNDAY_UNPRIVILEGED
      if SEASONS_SUNDAY_PRIMARY.include?(season_week.season)
        rank = Ranks::PRIMARY
      end

      week = Ordinalizer.ordinal season_week.week
      title = I18n.t "temporale.#{season_week.season.to_sym}.sunday", week: week

      self.class.create_celebration title, rank, season_week.season.colour, sunday: true
    end

    def ferial(date, season_week = nil)
      # Normally +season_week+ is provided, but the method is once called also from Calendar
      # and we definitely don't want Calendar to care that much about Temporale internals
      # So as to know how to retrieve the value, so in that case we provide it ourselves.
      season_week ||= season_and_week(date)

      rank = Ranks::FERIAL
      title = nil
      case season_week.season
      when Seasons::ADVENT
        if date >= Date.new(@year, 12, 17)
          rank = Ranks::FERIAL_PRIVILEGED
          nth = Ordinalizer.ordinal(date.day)
          title = I18n.t 'temporale.advent.before_christmas', day: nth
        end
      when Seasons::CHRISTMAS
        if date < mother_of_god
          rank = Ranks::FERIAL_PRIVILEGED

          nth = Ordinalizer.ordinal(date.day - nativity.day + 1) # 1-based counting
          title = I18n.t 'temporale.christmas.nativity_octave.ferial', day: nth
        elsif date > epiphany
          title = I18n.t 'temporale.christmas.after_epiphany.ferial', weekday: I18n.t("weekday.#{date.wday}")
        end
      when Seasons::LENT
        if season_week.week == 0
          title = I18n.t 'temporale.lent.after_ashes.ferial', weekday: I18n.t("weekday.#{date.wday}")
        elsif date > palm_sunday
          rank = Ranks::PRIMARY
          title = I18n.t 'temporale.lent.holy_week.ferial', weekday: I18n.t("weekday.#{date.wday}")
        end
        rank = Ranks::FERIAL_PRIVILEGED unless rank > Ranks::FERIAL_PRIVILEGED
      when Seasons::EASTER
        if season_week.week == 1
          rank = Ranks::PRIMARY
          title = I18n.t 'temporale.easter.octave.ferial', weekday: I18n.t("weekday.#{date.wday}")
        end
      end

      week_ord = Ordinalizer.ordinal season_week.week
      title ||= I18n.t "temporale.#{season_week.season.to_sym}.ferial", week: week_ord, weekday: I18n.t("weekday.#{date.wday}")

      self.class.create_celebration title, rank, season_week.season.colour
    end

    # helper: difference between two Dates in days
    def date_difference(d1, d2)
      (d1 - d2).numerator
    end

    # prepare dates of temporale solemnities
    def prepare_solemnities
      @solemnities = {}
      @feasts = {}
      @memorials = {}

      self.class.celebrations.each do |c|
        prepare_celebration_date c.date_method, c.celebration
      end

      @extensions.each do |extension|
        extension.each_celebration do |date_method, celebration|
          date_proc = date_method
          if date_method.is_a? Symbol
            date_proc = extension.method(date_method)
          end

          prepare_celebration_date date_proc, celebration
        end
      end

      @all_celebration_symbols = Set.new(
        @solemnities
          .merge(@feasts)
          .merge(@memorials)
          .each_value
          .collect(&:symbol)
          .compact # all should have a symbol, but we really want to prevent nil here
      )
    end

    def prepare_celebration_date(date_method, celebration)
      date =
        if date_method.respond_to? :call
          date_method.call(year)
        else
          public_send(date_method)
        end

      add_to =
        if celebration.feast?
          @feasts
        elsif celebration.memorial?
          @memorials
        else
          @solemnities
        end
      add_to[date] = celebration
    end

    def validate_sunday_transfer!
      unsupported = @transfer_to_sunday - SUNDAY_TRANSFERABLE_SOLEMNITIES
      unless unsupported.empty?
        raise RuntimeError.new("Transfer of #{unsupported.inspect} to a Sunday not supported. Only #{SUNDAY_TRANSFERABLE_SOLEMNITIES} are allowed.")
      end
    end
  end
end
