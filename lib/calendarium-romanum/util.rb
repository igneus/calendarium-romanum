module CalendariumRomanum

  module Util

    # Abstract superclass for date enumerators.
    class DateEnumerator
      include Enumerable

      def each
        d = @start
        begin
          yield d
          d = d.succ
        end until enumeration_over? d
      end

      def enumeration_over?(date)
        @start.send(@prop) != date.send(@prop)
      end

      alias_method :each_day, :each
    end

    # enumerates days of a year
    class Year < DateEnumerator
      def initialize(year)
        @start = Date.new year, 1, 1
        @prop = :year
      end
    end

    # enumerates days of a month
    class Month < DateEnumerator
      def initialize(year, month)
        @start = Date.new year, month, 1
        @prop = :month
      end
    end
  end
end
