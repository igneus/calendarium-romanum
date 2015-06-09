require 'date'

module CalendariumRomanum

  # determine dates of the Temporale feasts of the given year
  class Temporale

    WEEK = 7

    # year is Integer - the civil year when the liturgical year begins
    def initialize(year)
      @year = year
    end

    def weekday_before(weekday, date)
      if date.wday == weekday then
        return date - WEEK
      elsif weekday < date.wday
        return date - (date.wday - weekday)
      else
        return date - (date.wday + WEEK - weekday)
      end
    end

    def weekday_after(weekday, date)
      if date.wday == weekday then
        return date + WEEK
      elsif weekday > date.wday
        return date + (weekday - date.wday)
      else
        return date + (WEEK - date.wday + weekday)
      end
    end

    def method_missing(sym, *args)
      # translate messages like sunday_before and thursday_after
      weekdays = %w{sunday monday tuesday wednesday thursday friday saturday}
      if sym.to_s =~ /^(#{weekdays.join('|')})_(before|after)$/ then
        return send("weekday_#{$2}", weekdays.index($1), *args)
      end

      # first_advent_sunday -> advent_sunday(1)
      four = %w{first second third fourth}
      if sym.to_s =~ /^(#{four.join('|')})_advent_sunday$/ then
        return send("advent_sunday", four.index($1) + 1, *args)
      end
      
      raise NoMethodError.new sym
    end
1
    def advent_sunday(num, year=nil)
      advent_sundays_total = 4
      unless (1..advent_sundays_total).include? num
        raise ArgumentError.new "Invalid Advent Sunday #{num}"
      end

      year ||= @year
      return sunday_before(nativity(year)) - ((advent_sundays_total - num) * WEEK)
    end

    def nativity(year=nil)
      year ||= @year
      return Date.new(year, 12, 25)
    end

    def epiphany(year=nil)
      year ||= @year
      return Date.new(year+1, 1, 6)
    end

    def baptism_of_lord(year=nil)
      year ||= @year
      return sunday_after epiphany(year)
    end

    def ash_wednesday(year=nil)
      year ||= @year
      return easter_sunday(year) - (6 * WEEK + 4)
    end

    def easter_sunday(year=nil)
      year ||= @year
      year += 1

      # algorithm below taken from the 'easter' gem:
      # https://github.com/jrobertson/easter

      golden_number = (year % 19) + 1
      if year <= 1752 then
        # Julian calendar
        dominical_number = (year + (year / 4) + 5) % 7
        paschal_full_moon = (3 - (11 * golden_number) - 7) % 30
      else
        # Gregorian calendar
        dominical_number = (year + (year / 4) - (year / 100) + (year / 400)) % 7
        solar_correction = (year - 1600) / 100 - (year - 1600) / 400
        lunar_correction = (((year - 1400) / 100) * 8) / 25
        paschal_full_moon = (3 - 11 * golden_number + solar_correction - lunar_correction) % 30
      end
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

    def pentecost(year=nil)
      year ||= @year
      return easter_sunday(year) + 7 * WEEK
    end
  end
end