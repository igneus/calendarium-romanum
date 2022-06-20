require 'yaml'

module CalendariumRomanum
  class CLI
    # Produces a condensed text representation of a Calendar, used in regression tests.
    # Not loaded by default by +require 'calendarium-romanum'+
    #
    # @api private
    class Dumper
      def initialize(io=STDOUT)
        @io = io
      end

      # Dumps +calendar+. If +other_calendars+ are specified, dumps an alternative entry
      # for any date for which any of +other_calendars+ differs from +calendar+.
      def call(calendar, *other_calendars)
        @io.puts "Calendar for liturgical year #{calendar.year}"
        calendar.each do |day|
          dump_day(day)

          other_calendars.each do |cal|
            day2 = cal[day.date]
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
        calendar_with_extensions = Calendar.new(
          Temporale.new(year, extensions: Temporale::Extensions.all),
          sanctorale,
          vespers: true
        )

        I18n.with_locale(:la) do
          call(
            calendar,
            calendar_with_transfers,
            calendar_with_extensions,
          )
        end
      end

      # Produces the dump for solemnity transfer regression tests.
      #
      # @param years [Enumerable]
      def transfers_dump(years)
        sanctorale = Data::GENERAL_ROMAN_LATIN.load

        r = {}
        years.each do |year|
          calendar = Calendar.new(
            year,
            sanctorale
          )

          r[year] = calendar.transferred.transform_values do |celebration|
            celebration.symbol.to_s
          end
        end

        @io.puts YAML.dump r
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
end
