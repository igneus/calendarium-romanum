module CalendariumRomanum
  class Temporale
    # Provides methods computing dates of movable feasts
    # and utilities for common computations of relative dates
    module Dates
      include DateHelper
      extend self

      # (see #nativity)
      def first_advent_sunday(year)
        sunday_before(nativity(year)) - 3 * WEEK
      end

      # @param year [Integer] liturgical year
      # @return [Date]
      def nativity(year)
        Date.new(year, 12, 25)
      end

      # (see #nativity)
      def holy_family(year)
        xmas = nativity(year)
        if xmas.sunday?
          return Date.new(year, 12, 30)
        else
          sunday_after(xmas)
        end
      end

      # (see #nativity)
      def mother_of_god(year)
        octave_of(nativity(year))
      end

      # @param year [Integer] liturgical year
      # @param sunday [Boolean] transfer to Sunday?
      # @return [Date]
      def epiphany(year, sunday: false)
        if sunday
          # GNLYC 7 a)
          return sunday_after(Date.new(year + 1, 1, 1))
        end

        Date.new(year + 1, 1, 6)
      end

      # @param year [Integer] liturgical year
      # @param epiphany_on_sunday [Boolean] was Epiphany transferred to Sunday?
      # @return [Date]
      def baptism_of_lord(year, epiphany_on_sunday: false)
        e = epiphany(year, sunday: epiphany_on_sunday)
        if e.day > 6
          e + 1
        else
          sunday_after e
        end
      end

      # (see #nativity)
      def ash_wednesday(year)
        easter_sunday(year) - (6 * WEEK + 4)
      end

      # (see #nativity)
      def easter_sunday(year)
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
        paschal_full_moon -= 1 if (paschal_full_moon == 29) || ((paschal_full_moon == 28) && golden_number > 11)
        difference = (4 - paschal_full_moon - dominical_number) % 7
        difference += 7 if difference < 0
        day_easter = paschal_full_moon + difference + 1
        if day_easter < 11
          # Easter occurs in March.
          return Date.new(year, 3, day_easter + 21)
        else
          # Easter occurs in April.
          return Date.new(year, 4, day_easter - 10)
        end
      end

      # (see #nativity)
      def palm_sunday(year)
        easter_sunday(year) - 7
      end

      # (see #nativity)
      def good_friday(year)
        easter_sunday(year) - 2
      end

      # (see #nativity)
      def holy_saturday(year)
        easter_sunday(year) - 1
      end

      # (see .epiphany)
      def ascension(year, sunday: false)
        if sunday
          # GNLYC 7 b)
          return easter_sunday(year) + 6 * WEEK
        end

        pentecost(year) - 10
      end

      # (see #nativity)
      def pentecost(year)
        easter_sunday(year) + 7 * WEEK
      end

      # (see #nativity)
      def holy_trinity(year)
        octave_of(pentecost(year))
      end

      # (see .epiphany)
      def corpus_christi(year, sunday: false)
        if sunday
          # GNLYC 7 c)
          return holy_trinity(year) + WEEK
        end

        holy_trinity(year) + 4
      end

      # (see #nativity)
      def sacred_heart(year)
        corpus_christi(year) + 8
      end

      # (see #nativity)
      def mother_of_church(year)
        pentecost(year) + 1
      end

      # (see #nativity)
      def immaculate_heart(year)
        pentecost(year) + 20
      end

      # (see #nativity)
      def christ_king(year)
        first_advent_sunday(year + 1) - 7
      end
    end
  end
end
