module CalendariumRomanum
  class Temporale
    # dates of movable feasts
    module Dates
      def self.first_advent_sunday(year)
        sunday_before(nativity(year)) - 3 * WEEK
      end

      def self.nativity(year)
        Date.new(year, 12, 25)
      end

      def self.holy_family(year)
        xmas = nativity(year)
        if xmas.sunday?
          return Date.new(year, 12, 30)
        else
          sunday_after(xmas)
        end
      end

      def self.mother_of_god(year)
        octave_of(nativity(year))
      end

      def self.epiphany(year, sunday: false)
        if sunday
          # GNLYC 7 a)
          return sunday_after(Date.new(year + 1, 1, 1))
        end

        Date.new(year+1, 1, 6)
      end

      def self.baptism_of_lord(year)
        sunday_after epiphany(year)
      end

      def self.ash_wednesday(year)
        easter_sunday(year) - (6 * WEEK + 4)
      end

      def self.easter_sunday(year)
        year += 1

        # algorithm below taken from the 'easter' gem:
        # https://github.com/jrobertson/easter

        golden_number = (year % 19) + 1
        dominical_number = (year + (year / 4) - (year / 100) + (year / 400)) % 7
        solar_correction = (year - 1600) / 100 - (year - 1600) / 400
        lunar_correction = (((year - 1400) / 100) * 8) / 25
        paschal_full_moon = (3 - 11 * golden_number + solar_correction - lunar_correction) % 30
        dominical_number += 7 until dominical_number > 0
        paschal_full_moon += 30 until paschal_full_moon > 0
        paschal_full_moon -= 1 if paschal_full_moon == 29 or (paschal_full_moon == 28 and golden_number > 11)
        difference = (4 - paschal_full_moon - dominical_number) % 7
        difference += 7 if difference < 0
        day_easter = paschal_full_moon + difference + 1
        if day_easter < 11 then
          # Easter occurs in March.
          return Date.new(y=year, m=3, d=day_easter + 21)
        else
          # Easter occurs in April.
          return Date.new(y=year, m=4, d=day_easter - 10)
        end
      end

      def self.palm_sunday(year)
        easter_sunday(year) - 7
      end

      def self.good_friday(year)
        easter_sunday(year) - 2
      end

      def self.holy_saturday(year)
        easter_sunday(year) - 1
      end

      def self.ascension(year, sunday: false)
        if sunday
          # GNLYC 7 b)
          return easter_sunday(year) + 6 * WEEK
        end

        pentecost(year) - 10
      end

      def self.pentecost(year)
        easter_sunday(year) + 7 * WEEK
      end

      def self.holy_trinity(year)
        octave_of(pentecost(year))
      end

      def self.corpus_christi(year, sunday: false)
        if sunday
          # GNLYC 7 c)
          return holy_trinity(year) + WEEK
        end

        holy_trinity(year) + 4
      end

      def self.sacred_heart(year)
        corpus_christi(year) + 8
      end

      def self.immaculate_heart(year)
        pentecost(year) + 20
      end

      def self.christ_king(year)
        first_advent_sunday(year + 1) - 7
      end

      # utility methods

      def self.weekday_before(weekday, date)
        if date.wday == weekday then
          return date - WEEK
        elsif weekday < date.wday
          return date - (date.wday - weekday)
        else
          return date - (date.wday + WEEK - weekday)
        end
      end

      def self.weekday_after(weekday, date)
        if date.wday == weekday then
          return date + WEEK
        elsif weekday > date.wday
          return date + (weekday - date.wday)
        else
          return date + (WEEK - date.wday + weekday)
        end
      end

      def self.octave_of(date)
        date + WEEK
      end

      class << self
        WEEKDAYS = %w{sunday monday tuesday wednesday thursday friday saturday}
        WEEKDAYS.each_with_index do |weekday, weekday_i|
          define_method "#{weekday}_before" do |date|
            send('weekday_before', weekday_i, date)
          end

          define_method "#{weekday}_after" do |date|
            send('weekday_after', weekday_i, date)
          end
        end
      end
    end
  end
end
