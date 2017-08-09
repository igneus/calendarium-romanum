module CalendariumRomanum
  class Temporale
    module Extensions
      # Temporale extension adding feast of Christ Eternal Priests,
      # included in some local calendars
      module ChristEternalPriest
        def self.each_celebration
          yield(
            :christ_eternal_priest,
            Celebration.new(
              proc { I18n.t('temporale.extension.christ_eternal_priest') },
              Ranks::FEAST_PROPER,
              Colours::WHITE
            )
          )
        end

        # method computing date
        def self.christ_eternal_priest(year)
          Dates.pentecost(year) + 4
        end
      end
    end
  end
end
