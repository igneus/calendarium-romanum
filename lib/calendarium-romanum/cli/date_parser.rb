module CalendariumRomanum
  class CLI
    class DateParser
      def self.parse(date_str)
        /(?<year>\d{4})([\/-](?<month>\d{1,2})([\/-](?<day>\d{1,2}))?)?/.match(date_str) do |m|
          date_segments =
            %i(year month day)
              .collect {|name| m[name] }
              .compact
              .collect(&:to_i)

          build_range(*date_segments)
        end || raise(ArgumentError.new('Unparseable date'))
      end

      def self.build_range(*args)
        case args.size
        when 1
          Util::Year.new(*args)
        when 2
          Util::Month.new(*args)
        else
          date = Date.new(*args)
          date..date
        end
      end
    end
  end
end
