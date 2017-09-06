module CalendariumRomanum
  class Temporale
    class CelebrationFactory
      class << self
        def first_advent_sunday
          Celebration.new(
            I18n.t("temporale.advent.sunday", week: Ordinalizer.ordinal(1)),
            Ranks::PRIMARY,
            Colours::VIOLET
          )
        end
      end
    end
  end
end
