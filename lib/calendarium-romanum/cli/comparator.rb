module CalendariumRomanum
  class CLI
    # Compares two sanctorale data files, reports differences.
    class Comparator
      include Helper

      def call(a, b)
        paths = [a, b]
        sanctoralia = paths.collect {|source| sanctorale_from_path source }
        names = paths.collect {|source| File.basename source }

        # a leap year must be chosen in order to iterate over
        # all possible days of a Sanctorale
        Util::Year.new(1990).each_day do |d|
          a, b = sanctoralia.collect {|s| s.get(d) }

          0.upto([a.size, b.size].max - 1) do |i|
            ca = a[i]
            cb = b[i]
            compared = [ca, cb]

            if compared.index(&:nil?)
              notnili = compared.index {|c| !c.nil? }

              print date(d)
              puts " only in #{names[notnili]}:"
              puts celebration(compared[notnili])
              puts
              next
            end

            differences = %i(rank colour symbol).select do |property|
              ca.public_send(property) != cb.public_send(property)
            end

            next if differences.empty?
            print date(d)
            puts " differs in #{differences.join(', ')}"
            puts celebration(ca)
            puts celebration(cb)
            puts
          end
        end
      end

      private

      def date(d)
        "#{d.month}/#{d.day}"
      end

      def celebration(c)
        "#{c.rank.priority} #{c.colour.symbol} | #{c.title}"
      end
    end
  end
end
