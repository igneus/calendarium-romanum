module CalendariumRomanum
  class Temporale
    # Provides methods computing dates of movable feasts
    # and utilities for common computations of relative dates
    module Dates
      # (see .nativity)
      def self.first_advent_sunday(year)
        sunday_before(nativity(year)) - 3 * WEEK
      end

      # @param year [Integer] liturgical year
      # @return [Date]
      def self.nativity(year)
        Date.new(year, 12, 25)
      end

      # (see .nativity)
      def self.holy_family(year)
        xmas = nativity(year)
        if xmas.sunday?
          return Date.new(year, 12, 30)
        else
          sunday_after(xmas)
        end
      end

      # (see .nativity)
      def self.mother_of_god(year)
        octave_of(nativity(year))
      end

      # @param year [Integer] liturgical year
      # @param sunday [Boolean] transfer to Sunday?
      # @return [Date]
      def self.epiphany(year, sunday: false)
        if sunday
          # GNLYC 7 a)
          return sunday_after(Date.new(year + 1, 1, 1))
        end

        Date.new(year + 1, 1, 6)
      end

      # @param year [Integer] liturgical year
      # @param epiphany_on_sunday [Boolean] was Epiphany transferred to Sunday?
      # @return [Date]
      def self.baptism_of_lord(year, epiphany_on_sunday: false)
        # GNLYC 38)
        e = epiphany(year, sunday: epiphany_on_sunday)
        if e.mday > 6
          e + 1
        else
          sunday_after e
        end
      end

      # (see .nativity)
      def self.ash_wednesday(year)
        easter_sunday(year) - (6 * WEEK + 4)
      end

      # (see .nativity)
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

      # (see .nativity)
      def self.palm_sunday(year)
        easter_sunday(year) - 7
      end

      # (see .nativity)
      def self.good_friday(year)
        easter_sunday(year) - 2
      end

      # (see .nativity)
      def self.holy_saturday(year)
        easter_sunday(year) - 1
      end

      # (see .epiphany)
      def self.ascension(year, sunday: false)
        if sunday
          # GNLYC 7 b)
          return easter_sunday(year) + 6 * WEEK
        end

        pentecost(year) - 10
      end

      # (see .nativity)
      def self.pentecost(year)
        easter_sunday(year) + 7 * WEEK
      end

      # (see .nativity)
      def self.holy_trinity(year)
        octave_of(pentecost(year))
      end

      # (see .epiphany)
      def self.corpus_christi(year, sunday: false)
        if sunday
          # GNLYC 7 c)
          return holy_trinity(year) + WEEK
        end

        holy_trinity(year) + 4
      end

      # (see .nativity)
      def self.sacred_heart(year)
        corpus_christi(year) + 8
      end

      # (see .nativity)
      def self.mother_of_church(year)
        pentecost(year) + 1
      end

      # (see .nativity)
      def self.immaculate_heart(year)
        pentecost(year) + 20
      end

      # (see .nativity)
      def self.christ_king(year)
        first_advent_sunday(year + 1) - 7
      end

      # utility methods

      # @param weekday [Integer]
      # @param date [Date]
      # @return [Date]
      def self.weekday_before(weekday, date)
        if date.wday == weekday
          date - WEEK
        elsif weekday < date.wday
          date - (date.wday - weekday)
        else
          date - (date.wday + WEEK - weekday)
        end
      end

      # (see .weekday_before)
      def self.weekday_after(weekday, date)
        if date.wday == weekday
          date + WEEK
        elsif weekday > date.wday
          date + (weekday - date.wday)
        else
          date + (WEEK - date.wday + weekday)
        end
      end

      # @param date [Date]
      # @return [Date]
      def self.octave_of(date)
        date + WEEK
      end

      class << self
        # @!method sunday_before(date)
        #   @param date [Date]
        #   @return [Date]
        # @!method monday_before(date)
        #   (see .sunday_before)
        # @!method tuesday_before(date)
        #   (see .sunday_before)
        # @!method wednesday_before(date)
        #   (see .sunday_before)
        # @!method thursday_before(date)
        #   (see .sunday_before)
        # @!method friday_before(date)
        #   (see .sunday_before)
        # @!method saturday_before(date)
        #   (see .sunday_before)

        # @!method sunday_after(date)
        #   @param date [Date]
        #   @return [Date]
        # @!method monday_after(date)
        #   (see .sunday_after)
        # @!method tuesday_after(date)
        #   (see .sunday_after)
        # @!method wednesday_after(date)
        #   (see .sunday_after)
        # @!method thursday_after(date)
        #   (see .sunday_after)
        # @!method friday_after(date)
        #   (see .sunday_after)
        # @!method saturday_after(date)
        #   (see .sunday_after)

        # @api private
        WEEKDAYS = %w(sunday monday tuesday wednesday thursday friday saturday).freeze
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
