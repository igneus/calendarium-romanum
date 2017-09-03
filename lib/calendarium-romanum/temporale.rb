require 'date'

module CalendariumRomanum

  # determine seasons and dates of the Temporale feasts of the given year
  class Temporale

    WEEK = 7

    SUNDAY_TRANSFERABLE_SOLEMNITIES =
      %i(epiphany ascension corpus_christi).freeze

    # year is Integer - the civil year when the liturgical year begins
    def initialize(year, extensions: [], transfer_to_sunday: [])
      @year = year

      @extensions = extensions
      @transfer_to_sunday = transfer_to_sunday
      validate_sunday_transfer!

      prepare_solemnities
    end

    attr_reader :year

    class << self
      # Determines liturgical year for the given date
      def liturgical_year(date)
        year = date.year
        temporale = Temporale.new year

        if date < temporale.first_advent_sunday
          return year - 1
        end

        return year
      end

      # creates a Calendar for the liturgical year including given
      # date
      def for_day(date)
        return new(liturgical_year(date))
      end

      C = Struct.new(:date_method, :celebration)
      private_constant :C

      # implementation detail, not to be touched by client code
      def celebrations
        @celebrations ||=
          begin
            [
              c(:nativity, Ranks::PRIMARY),
              c(:holy_family, Ranks::FEAST_LORD_GENERAL),
              c(:mother_of_god, Ranks::SOLEMNITY_GENERAL),
              c(:epiphany, Ranks::PRIMARY),
              c(:baptism_of_lord, Ranks::FEAST_LORD_GENERAL),
              c(:ash_wednesday, Ranks::PRIMARY, Colours::VIOLET),
              c(:good_friday, Ranks::TRIDUUM, Colours::RED),
              c(:holy_saturday, Ranks::TRIDUUM, Colours::VIOLET),
              c(:palm_sunday, Ranks::PRIMARY, Colours::RED),
              c(:easter_sunday, Ranks::TRIDUUM),
              c(:ascension, Ranks::PRIMARY),
              c(:pentecost, Ranks::PRIMARY, Colours::RED),
              c(:holy_trinity, Ranks::SOLEMNITY_GENERAL),
              c(:corpus_christi, Ranks::SOLEMNITY_GENERAL),
              c(:sacred_heart, Ranks::SOLEMNITY_GENERAL),
              c(:christ_king, Ranks::SOLEMNITY_GENERAL),

              # Immaculate Heart of Mary is actually (currently the only one)
              # movable *sanctorale* feast, but as it would make little sense
              # to add support for movable sanctorale feasts because of
              # a single one, we cheat a bit and handle it in temporale.
              c(:immaculate_heart, Ranks::MEMORIAL_GENERAL),
            ]
          end
      end

      private

      def c(date_method, rank, colour=Colours::WHITE)
        title = proc { I18n.t("temporale.solemnity.#{date_method}") }

        C.new(
          date_method,
          Celebration.new(title, rank, colour, date_method)
        )
      end
    end

    def transferred_to_sunday?(solemnity)
      @transfer_to_sunday.include?(solemnity)
    end

    def start_date
      first_advent_sunday
    end

    def end_date
      Dates.first_advent_sunday(year+1) - 1
    end

    def date_range
      start_date .. end_date
    end

    def range_check(date)
      # necessary in order to handle Date correctly
      date = date.to_date if date.class != Date

      unless date_range.include? date
        raise RangeError.new "Date out of range #{date}"
      end
    end

    %i(
    first_advent_sunday
    nativity
    holy_family
    mother_of_god
    epiphany
    baptism_of_lord
    ash_wednesday
    palm_sunday
    good_friday
    holy_saturday
    easter_sunday
    ascension
    pentecost
    holy_trinity
    corpus_christi
    sacred_heart
    immaculate_heart
    christ_king
    ).each do |feast|
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

    # which liturgical season is it?
    def season(date)
      range_check date

      if first_advent_sunday <= date and
          nativity > date then
        Seasons::ADVENT

      elsif nativity <= date and
          baptism_of_lord >= date then
        Seasons::CHRISTMAS

      elsif ash_wednesday <= date and
          easter_sunday > date then
        Seasons::LENT

      elsif easter_sunday <= date and
          pentecost >= date then
        Seasons::EASTER

      else
        Seasons::ORDINARY
      end
    end

    def season_beginning(s)
      case s
      when Seasons::ADVENT
        first_advent_sunday
      when Seasons::CHRISTMAS
        nativity
      when Seasons::LENT
        ash_wednesday
      when Seasons::EASTER
        easter_sunday
      when Seasons::ORDINARY # ordinary time
        baptism_of_lord + 1
      else
        raise ArgumentError.new('unsupported season')
      end
    end

    def season_week(seasonn, date)
      week1_beginning = season_beginning = season_beginning(seasonn)
      unless season_beginning.sunday?
        week1_beginning = Dates.sunday_after(season_beginning)
      end

      week = date_difference(date, week1_beginning) / WEEK + 1

      if seasonn == Seasons::ORDINARY
        # ordinary time does not begin with Sunday, but the first week
        # is week 1, not 0
        week += 1

        if date > pentecost
          weeks_after_date = date_difference(Dates.first_advent_sunday(@year + 1), date) / 7
          week = 34 - weeks_after_date
          week += 1 if date.sunday?
        end
      end

      return week
    end

    # returns a Celebration
    # scheduled for the given day
    #
    # expected arguments: Date or two Integers (month, day)
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

      return @solemnities[date] || @feasts[date] || sunday(date) || @memorials[date] || ferial(date)
    end

    private

    # seasons when Sundays have higher rank
    SEASONS_SUNDAY_PRIMARY = [Seasons::ADVENT, Seasons::LENT, Seasons::EASTER].freeze

    def sunday(date)
      return nil unless date.sunday?

      seas = season date
      rank = Ranks::SUNDAY_UNPRIVILEGED
      if SEASONS_SUNDAY_PRIMARY.include?(seas)
        rank = Ranks::PRIMARY
      end

      week = Ordinalizer.ordinal season_week(seas, date)
      title = I18n.t "temporale.#{seas.to_sym}.sunday", week: week

      return Celebration.new title, rank, seas.colour
    end

    def ferial(date)
      seas = season date
      week = season_week(seas, date)
      rank = Ranks::FERIAL
      title = nil
      case seas
      when Seasons::ADVENT
        if date >= Date.new(@year, 12, 17)
          rank = Ranks::FERIAL_PRIVILEGED
        end
      when Seasons::CHRISTMAS
        if date < mother_of_god
          rank = Ranks::FERIAL_PRIVILEGED

          nth = Ordinalizer.ordinal(date.day - nativity.day + 1) # 1-based counting
          title = I18n.t 'temporale.christmas.nativity_octave.ferial', day: nth
        elsif date > epiphany
          title = I18n.t "temporale.christmas.after_epiphany.ferial", weekday: I18n.t("weekday.#{date.wday}")
        end
      when Seasons::LENT
        if week == 0
          title = I18n.t "temporale.lent.after_ashes.ferial", weekday: I18n.t("weekday.#{date.wday}")
        elsif date > palm_sunday
          rank = Ranks::PRIMARY
          title = I18n.t "temporale.lent.holy_week.ferial", weekday: I18n.t("weekday.#{date.wday}")
        end
        rank = Ranks::FERIAL_PRIVILEGED unless rank > Ranks::FERIAL_PRIVILEGED
      when Seasons::EASTER
        if week == 1
          rank = Ranks::PRIMARY
          title = I18n.t "temporale.easter.octave.ferial", weekday: I18n.t("weekday.#{date.wday}")
        end
      end

      week_ord = Ordinalizer.ordinal week
      title ||= I18n.t "temporale.#{seas.to_sym}.ferial", week: week_ord, weekday: I18n.t("weekday.#{date.wday}")

      return Celebration.new title, rank, seas.colour
    end

    # helper: difference between two Dates in days
    def date_difference(d1, d2)
      return (d1 - d2).numerator
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
    end

    def prepare_celebration_date(date_method, celebration)
      if date_method.respond_to? :call
        date = date_method.call(year)
      else
        date = public_send(date_method)
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
