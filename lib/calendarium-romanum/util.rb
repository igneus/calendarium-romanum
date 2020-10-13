module CalendariumRomanum

  # General utilities, not tied to the business domain
  # of liturgical calendar computation.
  module Util

    # Abstract superclass for date enumerators.
    # @abstract
    class DateEnumerator
      include Enumerable

      # @yield [Date]
      # @return [void, Enumerator]
      def each
        return to_enum(__method__) unless block_given?

        d = @start
        begin
          yield d
          d = d.succ
        end until enumeration_over? d
      end

      # @param date [Date]
      # @return [Boolean]
      def enumeration_over?(date)
        @start.send(@prop) != date.send(@prop)
      end

      alias each_day each
    end

    # Enumerates days of a year
    class Year < DateEnumerator
      def initialize(year)
        @start = Date.new year, 1, 1
        @prop = :year
      end
    end

    # Enumerates days of a month
    class Month < DateEnumerator
      def initialize(year, month)
        @start = Date.new year, month, 1
        @prop = :month
      end
    end
  end
end
