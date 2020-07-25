module CalendariumRomanum
  # Produces a condensed text representation of a Calendar, used in regression tests.
  # Not loaded by default by +require 'calendarium-romanum'+
  #
  # @api private
  class Dumper
    def initialize(io=STDOUT)
      @io = io
    end

    def call(calendar)
      @io.puts "Calendar for liturgical year #{calendar.year}"
      calendar.each do |day|
        @io.puts [day.date, day.season.symbol, day.season_week, !day.vespers.nil?].join(' ')

        day.celebrations.each do |c|
          @io.puts ['-', c.title.inspect, c.rank.priority, c.colour.symbol, c.symbol, (c.date && "#{c.date.month}/#{c.date.day}"), c.cycle].join(' ')
        end
      end
    end
  end
end
