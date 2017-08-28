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
        # when :it # TODO
        when :la, :it
          RomanNumerals.to_roman number
        else
          number
        end
      end

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
    end
  end
end
