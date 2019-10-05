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

    # @api private
    class DateParser
      def initialize(date_str)
        if date_str =~ /((\d{4})(\/|-)?(\d{0,2})(\/|-)?(\d{0,2}))\z/ # Accepts YYYY-MM-DD, YYYY/MM/DD where both day and month are optional
          year = Regexp.last_match(2).to_i
          month = Regexp.last_match(4).to_i
          day = Regexp.last_match(6).to_i
          @date_range = if (day == 0) && (month == 0) # Only year is given
                          Year.new(year)
                        elsif day == 0 # Year and month are given
                          Month.new(year, month)
                        else
                          Date.new(year, month, day)..Date.new(year, month, day)
                        end
        else
          raise ArgumentError, 'Unparseable date'
        end
      end

      # @return [DateEnumerator, Range]
      attr_reader :date_range
    end

  end
end
