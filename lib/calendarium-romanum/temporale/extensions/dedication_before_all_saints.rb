module CalendariumRomanum
  class Temporale
    module Extensions
      # {Temporale} extension adding solemnity of dedication
      # of a church celebrated on the Sunday before All Saints /
      # last October Sunday.
      #
      # In churches, whose actual day of consecration is unknown, the anniversary
      # of consecration is celebrated either on October 25th, or on the Sunday
      # before All Saints (cf. Notitiae 71/1972, p. 103).
      # This extension implements the latter case.
      #
      # @example
      #   # It can be used either this way
      #   temporale = Temporale.new(2015, extensions: [
      #     Temporale::Extensions::DedicationBeforeAllSaints
      #   ])
      #
      #   # Or, if you want to customize celebration title and/or symbol:
      #   temporale = Temporale.new(2015, extensions: [
      #     Temporale::Extensions::DedicationBeforeAllSaints.new(title: 'Title', symbol: :symbol)
      #   ])
      #
      # @since 0.8.0
      class DedicationBeforeAllSaints
        DEFAULT_TITLE = proc { I18n.t('temporale.extension.dedication') }
        DEFAULT_SYMBOL = :dedication

        # @yield [Symbol, Celebration]
        # @return [void]
        def self.each_celebration
          yield(
            # symbol refers to the date-computing method
            :dedication,
            Celebration.new(
              DEFAULT_TITLE,
              Ranks::SOLEMNITY_PROPER,
              Colours::WHITE,
              DEFAULT_SYMBOL
            )
          )
        end

        # Computes date of the solemnity
        #
        # @param year [Integer] liturgical year
        # @return [Date]
        def self.dedication(year)
          Dates.sunday_before(Date.new(year + 1, 11, 1))
        end

        def initialize(title: DEFAULT_TITLE, symbol: DEFAULT_SYMBOL)
          @title = title
          @symbol = symbol
        end

        # @yield [Symbol, Celebration]
        # @return [void]
        def each_celebration
          yield(
            proc {|year| self.class.dedication(year) },
            Celebration.new(
              @title,
              Ranks::SOLEMNITY_PROPER,
              Colours::WHITE,
              @symbol
            )
          )
        end
      end
    end
  end
end
