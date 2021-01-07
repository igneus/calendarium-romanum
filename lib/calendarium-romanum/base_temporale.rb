module CalendariumRomanum
  class BaseTemporale
    class << self
      # List of celebrations with movable date
      def celebrations
        @celebrations ||=
          if superclass.respond_to? :celebrations
            superclass.celebrations.dup
          else
            []
          end
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

      # @return [Array<Season>]
      def seasons
        @seasons ||
          (superclass.respond_to?(:seasons) && superclass.seasons) ||
          [Season.new(nil, nil) { true }]
      end

      private

      C = Struct.new(:date_method, :celebration)
      private_constant :C

      # Call in class body to define a movable celebration
      def celebration(symbol, date: nil, &blk)
        date_callable = date || celebration_dates_provider.method(symbol)

        celebrations << C.new(
          date_callable,
          blk ? blk.call : get_celebration_factory.public_send(symbol)
        )

        # Define instance method returning the celebration's date for the given year
        define_method symbol do
          date_callable.call year
        end
      end

      # Call in class body to set custom celebration dates provider
      def celebration_dates(provider)
        @celebration_dates_provider = provider
      end

      # Call in class body to set custom celebration factory
      def celebration_factory(factory)
        @celebration_factory = factory
      end

      def set_seasons(ary)
        @seasons = ary
      end

      # @api private
      def celebration_dates_provider
        @celebration_dates_provider ||
          Temporale::Dates
      end

      # @api private
      def get_celebration_factory
        @celebration_factory ||
          Temporale::CelebrationFactory
      end
    end

    def initialize(year)
      @year = year

      prepare_solemnities
    end

    # @return [Integer]
    attr_reader :year

    # First day of the liturgical year
    #
    # @return [Date]
    def start_date
      Temporale::Dates.first_advent_sunday(year)
    end

    # Last day of the liturgical year
    #
    # @return [Date]
    def end_date
      Temporale::Dates.first_advent_sunday(year + 1) - 1
    end

    # Date range of the liturgical year
    #
    # @return [Range<Date>]
    def date_range
      start_date .. end_date
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

    # Enumerates dates and celebrations
    #
    # @yield [Date, Celebration]
    # @return [void, Enumerator] if called without a block, returns +Enumerator+
    # @since 0.8.0
    def each_day
      return to_enum(__method__) unless block_given?

      date_range.each {|date| yield date, self[date] }
    end

    def season(date)
      r = self.class.seasons.find {|s| s.include? date, self }
      raise RuntimeError.new("No season found for #{date}") if r.nil?

      r
    end

    def season_week(season, date)
      1
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

    # prepare dates of temporale solemnities
    def prepare_solemnities
      @solemnities = {}
      @feasts = {}
      @memorials = {}

      self.class.celebrations.each do |c|
        prepare_celebration_date c.date_method, c.celebration
      end
    end

    def prepare_celebration_date(date_callable, celebration)
      date = date_callable.call(year)

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
  end
end
