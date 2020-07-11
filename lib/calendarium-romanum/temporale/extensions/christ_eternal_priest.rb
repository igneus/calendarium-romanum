module CalendariumRomanum
  class Temporale
    module Extensions
      # {Temporale} extension adding the movable feast
      # of "Christ Eternal Priests",
      # included in some local calendars
      #
      # @example
      #   temporale = Temporale.new(2015, extensions: [
      #     Temporale::Extensions::ChristEternalPriest
      #   ])
      module ChristEternalPriest
        # @yield [Symbol, Celebration]
        # @return [void]
        def self.each_celebration
          yield(
            # symbol refers to the date-computing method
            :christ_eternal_priest,
            Celebration.new(
              proc { I18n.t('temporale.extension.christ_eternal_priest') },
              Ranks::FEAST_PROPER,
              Colours::WHITE
            )
          )
        end

        # Computes the feast's date
        #
        # @param year [Integer] liturgical year
        # @return [Date]
        def self.christ_eternal_priest(year)
          Dates.pentecost(year) + 4
        end
      end
    end
  end
end
