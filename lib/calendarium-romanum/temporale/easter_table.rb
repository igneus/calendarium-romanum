module CalendariumRomanum
  class Temporale
    class EasterTable
      # Loads an Easter table from a String- or IO-like object +src+.
      # +src+ must contain Easter dates, parseable by +Date.parse+, one date per line.
      # Blank lines and bash-like comments are ignored.
      # Returns a +Hash+ mapping (liturgical) year to Easter date.
      #
      # @param src [#each_line]
      # @return [Hash<Integer=>Date>]
      def self.load_from(src)
        r = {}
        src.each_line do |l|
          cleaned = l.sub(/#.*$/, '').strip
          next if cleaned == ''

          date = Date.parse cleaned
          liturgical_year = date.year - 1
          r[liturgical_year] = date
        end

        r
      end
    end
  end
end
