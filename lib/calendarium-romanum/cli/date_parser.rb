module CalendariumRomanum
  class CLI
    # @api private
    class DateParser
      def initialize(date_str)
        if date_str =~ /((\d{4})(\/|-)?(\d{0,2})(\/|-)?(\d{0,2}))\z/ # Accepts YYYY-MM-DD, YYYY/MM/DD where both day and month are optional
          year = Regexp.last_match(2).to_i
          month = Regexp.last_match(4).to_i
          day = Regexp.last_match(6).to_i
          @date_range = if (day == 0) && (month == 0) # Only year is given
                          Util::Year.new(year)
                        elsif day == 0 # Year and month are given
                          Util::Month.new(year, month)
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
