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
        when :la
          RomanNumerals.to_roman number
        else
          number
        end
      end

      def english_ordinal(number)
        case number
        when 1
          '1st'
        when 2
          '2nd'
        when 3
          '3rd'
        else
          "#{number}th"
        end
      end
    end
  end
end
