require 'set'

module CalendariumRomanum
  class CLI
    # Compares two sanctorale data files, reports differences.
    #
    # @api private
    class Comparator
      include Helper

      SUPPORTED_PROPERTIES = %i(rank colour symbol title)
      DEFAULT_PROPERTIES = SUPPORTED_PROPERTIES - %i(title)

      def initialize(properties = DEFAULT_PROPERTIES)
        unless Set.new(properties) <= Set.new(SUPPORTED_PROPERTIES)
          raise ArgumentError.new("Unsupported properties specified: #{properties} Only #{SUPPORTED_PROPERTIES} are supported")
        end

        @properties = properties
      end

      def call(path_a, path_b)
        paths = [path_a, path_b]
        sanctoralia = paths.collect {|source| sanctorale_from_path source }
        names = paths.collect {|source| File.basename source }

        differences_found = false
        all_possible_dates.each do |d|
          a, b = sanctoralia.collect {|sanctorale| sanctorale[d] }

          0.upto([a.size, b.size].max - 1) do |i|
            ca = a[i]
            cb = b[i]
            compared = [ca, cb]

            if compared.index(&:nil?)
              differences_found = true
              notnili = compared.index {|c| !c.nil? }

              print date(d)
              puts " only in #{names[notnili]}:"
              puts celebration(compared[notnili])
              puts
              next
            end

            differences = @properties.select do |property|
              ca.public_send(property) != cb.public_send(property)
            end

            next if differences.empty?
            differences_found = true
            print date(d)
            puts " differs in #{differences.join(', ')}"
            puts celebration(ca)
            puts celebration(cb)
            puts
          end
        end

        !differences_found
      end

      private

      def all_possible_dates
        # a leap year must be chosen in order to iterate over
        # all possible days of a Sanctorale
        Util::Year.new(1990).each_day
      end

      def date(d)
        "#{d.month}/#{d.day}"
      end

      def celebration(c)
        symbol_chunk = c.symbol && "#{c.symbol} | "

        "#{c.rank.priority} #{c.colour.symbol} | #{symbol_chunk}#{c.title}"
      end
    end
  end
end
