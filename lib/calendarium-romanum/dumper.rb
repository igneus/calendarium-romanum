module CalendariumRomanum
  # Produces a condensed text representation of a Calendar, used in regression tests.
  # Not loaded by default by +require 'calendarium-romanum'+
  #
  # @api private
  class Dumper
    def initialize(io=STDOUT)
      @io = io
    end

    # Dumps +calendar+. If +calendar2+ is specified, dumps an alternative entry
    # for any date for which +calendar2+ differs from +calendar+.
    def call(calendar, calendar2=nil)
      @io.puts "Calendar for liturgical year #{calendar.year}"
      calendar.each do |day|
        dump_day(day)

        if calendar2
          day2 = calendar2[day.date]
          if day2 != day
            @io.print 'or '
            dump_day(day2)
          end
        end
      end
    end

    # Produces the dump used for regression tests for the specified +year+.
    def regression_tests_dump(year)
      sanctorale = Data::GENERAL_ROMAN_LATIN.load
      calendar = Calendar.new(
        year,
        sanctorale,
        vespers: true
      )
      calendar_with_transfers = Calendar.new(
        Temporale.new(year, transfer_to_sunday: Temporale::SUNDAY_TRANSFERABLE_SOLEMNITIES),
        sanctorale,
        vespers: true
      )

      I18n.with_locale(:la) do
        call(calendar, calendar_with_transfers)
      end
    end

    private

    def dump_day(day)
      @io.puts [day.date, day.season.symbol, day.season_week, !day.vespers.nil?].join(' ')

      day.celebrations.each do |c|
        @io.puts ['-', c.title.inspect, c.rank.priority, c.colour.symbol, c.symbol, (c.date && "#{c.date.month}/#{c.date.day}"), c.cycle].join(' ')
      end
    end
  end
end
