require 'roman-numerals'

module CalendariumRomanum
  # Knows how to produce localized ordinals
  class Ordinalizer
    class << self
      def ordinal(number, locale: nil)
        locale ||= I18n.locale

        case locale
        when :cs
          "#{number}."
        when :en
          english_ordinal(number)
        when :fr
          french_ordinal(number)
        when :la, :it
          RomanNumerals.to_roman number
        else
          number
        end
      end

      private

      def english_ordinal(number)
        modulo = number % 10
        modulo = 9 if number / 10 == 1

        case modulo
        when 1
          "#{number}st"
        when 2
          "#{number}nd"
        when 3
          "#{number}rd"
        else
          "#{number}th"
        end
      end

      def french_ordinal(number)
        case number
        when 1
          '1er'
        else
          "#{number}ème"
        end
      end
    end
  end
end
