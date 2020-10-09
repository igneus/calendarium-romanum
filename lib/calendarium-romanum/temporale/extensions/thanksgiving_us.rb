module CalendariumRomanum
  class Temporale
    module Extensions
      # {Temporale} extension adding the movable feast
      # of "Thanksgiving", included in the USA
      #
      # @example
      #   temporale = Temporale.new(2015, extensions: [
      #     Temporale::Extensions::ThanksgivingUS
      #   ])
      module ThanksgivingUS
        # @yield [Symbol, Celebration]
        # @return [void]
        def self.each_celebration
          yield(
            # symbol refers to the date-computing method
            :thanksgiving,
            Celebration.new(
              proc { I18n.t('temporale.extension.thanksgiving') },
              Ranks::MEMORIAL_OPTIONAL,
              Colours::WHITE,
              :thanksgiving
            )
          )
        end

        # Computes the feast's date
        #
        # @param year [Integer] liturgical year
        # @return [Date]
        def self.thanksgiving(year)
          # Fourth Thursday of November
          puts Dates.thursday_after(Date.new(year + 1, 11, 21))
          Dates.thursday_after(Date.new(year + 1, 11, 21))
        end  
      end
    end
  end
end
