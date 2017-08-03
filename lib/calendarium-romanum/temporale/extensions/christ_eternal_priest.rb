module CalendariumRomanum
  class Temporale
    module Extensions
      # Temporale extension adding feast of Christ Eternal Priests,
      # included in some local calendars
      module ChristEternalPriest
        def self.included(mod)
          mod.add_celebration(:christ_eternal_priest, Ranks::FEAST_PROPER, Colours::WHITE, proc { I18n.t('temporale.extension.christ_eternal_priest') })
        end

        # method computing date
        def christ_eternal_priest
          pentecost + 4
        end
      end
    end
  end
end
