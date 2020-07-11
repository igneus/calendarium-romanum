module CalendariumRomanum
  # Has mostly the same public interface as {Calendar},
  # but represents a "perpetual" calendar, not a calendar
  # for a single year, thus allowing the client code
  # to query for liturgical data of any day, without bothering
  # about boundaries of liturgical years.
  #
  # Internally builds {Calendar} instances as needed
  # and delegates method calls to them.
  #
  # @since 0.4.0
  class PerpetualCalendar
    # @param sanctorale [Sanctorale, nil]
    # @param temporale_factory [Proc, nil]
    #   +Proc+ receiving a single parameter - year - and returning
    #   a {Temporale} instance.
    # @param temporale_options [Hash, nil]
    #   +Hash+ of arguments for {Temporale#initialize}.
    #   +temporale_factory+ and +temporale_options+ are mutually
    #   exclusive - pass either (or none) of them, never both.
    # @param cache [Hash]
    #   object to be used as internal cache of {Calendar} instances -
    #   anything exposing +#[]=+ and +#[]+ and "behaving mostly like
    #   a +Hash+" will work.
    #   There's no need to pass it unless you want to have control
    #   over the cache. That may be sometimes useful
    #   in order to prevent a long-lived
    #   +PerpetualCalendar+ instance flooding the memory
    #   by huge amount of cached {Calendar} instances.
    #   (By default, once a {Calendar} for a certain year is built,
    #   it is cached for the +PerpetualCalendar+ instances' lifetime.)
    def initialize(sanctorale: nil, temporale_factory: nil, temporale_options: nil, cache: {})
      if temporale_factory && temporale_options
        raise ArgumentError.new('Specify either temporale_factory or temporale_options, not both')
      end

      @sanctorale = sanctorale
      @temporale_factory = temporale_factory || build_temporale_factory(temporale_options)

      @cache = cache
    end

    # @return [Day]
    # @see Calendar#day
    def day(*args, vespers: false, vigils: false)
      calendar_for(*args).day(*args, vespers: vespers, vigils: vigils)
    end

    # @return [Day, Array<Day>]
    # @see Calendar#[]
    # @since 0.6.0
    def [](arg)
      if arg.is_a? Range
        return arg.collect do |date|
          calendar_for(date).day(date)
        end
      end

      day(arg)
    end

    # Returns a {Calendar} instance for the liturgical year containing
    # the specified day
    #
    # Parameters like {Calendar#day}
    #
    # @return [Calendar]
    def calendar_for(*args)
      date = Calendar.mk_date(*args)
      year = Temporale.liturgical_year date
      calendar_instance year
    end

    # Returns a Calendar instance for the specified liturgical year
    #
    # @param year [Integer]
    # @return [Calendar]
    def calendar_for_year(year)
      calendar_instance year
    end

    private

    def build_temporale_factory(temporale_options)
      temporale_options ||= {}
      lambda {|year| Temporale.new(year, **temporale_options) }
    end

    def calendar_instance(year)
      if @cache.has_key? year
        @cache[year]
      else
        @cache[year] = Calendar.new(year, @sanctorale, @temporale_factory.call(year))
      end
    end
  end
end
