module CalendariumRomanum
  # When you want to query a calendar without caring about
  # civil and liturgical years and Calendar instances
  class PerpetualCalendar
    def initialize(sanctorale: nil, temporale_factory: nil, temporale_options: nil, cache: {})
      if temporale_factory && temporale_options
        raise ArgumentError.new('Specify either temporale_factory or temporale_options, not both')
      end

      @sanctorale = sanctorale
      @temporale_factory = temporale_factory || build_temporale_factory(temporale_options)

      @cache = cache
    end

    # returns a resolved Day
    def day(*args)
      calendar_for(*args).day(*args)
    end

    def [](arg)
      if arg.is_a? Range
        return arg.collect do |date|
          calendar_for(date).day(date)
        end
      end

      day(arg)
    end

    # returns a Calendar instance for the liturgical year containing
    # the specified day
    def calendar_for(*args)
      date = Calendar.mk_date(*args)
      year = Temporale.liturgical_year date
      calendar_instance year
    end

    # returns a Calendar instance for the specified liturgical year
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
