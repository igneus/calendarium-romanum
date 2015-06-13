require 'date'

module CalendariumRomanum

  # determine seasons and dates of the Temporale feasts of the given year
  class Temporale

    WEEK = 7

    SEASON_COLOUR = {
                     Seasons::ADVENT => Colours::VIOLET,
                     Seasons::CHRISTMAS => Colours::WHITE,
                     Seasons::ORDINARY => Colours::GREEN,
                     Seasons::LENT => Colours::VIOLET,
                     Seasons::EASTER => Colours::WHITE,
                    }

    # year is Integer - the civil year when the liturgical year begins
    def initialize(year)
      @year = year
    end

    # DateTime of a year beginning
    # 00:00 of the first Advent Sunday
    def dt_beginning
      first_advent_sunday.to_datetime
    end

    # DateTime of a year end
    # 23:59 of the last Saturday
    def dt_end
      day = advent_sunday(1, @year+1) - 1
      return DateTime.new(day.year, day.month, day.day, 23, 59, 59)
    end

    def dt_range
      dt_beginning .. dt_end
    end

    def range_check(date)
      unless dt_range.include? date
        raise RangeError.new "Date out of range #{date}"
      end
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

    # which liturgical season is it?
    def season(date)
      range_check date

      if first_advent_sunday <= date and
          nativity > date then
        Seasons::ADVENT

      elsif nativity <= date and
          baptism_of_lord >= date then
        Seasons::CHRISTMAS

      elsif ash_wednesday <= date and
          easter_sunday > date then
        Seasons::LENT

      elsif easter_sunday <= date and
          pentecost >= date then
        Seasons::EASTER

      else
        Seasons::ORDINARY
      end
    end

    def season_beginning(s)
      case s
      when Seasons::ADVENT
        first_advent_sunday
      when Seasons::CHRISTMAS
        nativity
      when Seasons::LENT
        ash_wednesday
      when Seasons::EASTER
        easter_sunday
      else # ordinary time
        monday_after(baptism_of_lord)
      end
    end

    def season_week(seasonn, date)
      week1_beginning = season_beginning = season_beginning(seasonn)
      unless season_beginning.sunday?
        week1_beginning = sunday_after(season_beginning)
      end

      week = date_difference(date, week1_beginning) / Temporale::WEEK + 1

      if seasonn == Seasons::ORDINARY
        # ordinary time does not begin with Sunday, but the first week
        # is week 1, not 0
        week += 1

        if date > pentecost
          # gap made by Lent and Easter time
          week -= 12
        end
      end

      return week
    end

    # returns a Celebrations
    # scheduled for the given day
    #
    # expected arguments: Date or two Integers (month, day)
    def get(*args)
      if args.size == 1 && args[0].is_a?(Date)
        date = args[0]
      else
        month, day = args
        date = Date.new @year, month, day
        unless dt_range.include? date
          date = Date.new @year + 1, month, day
        end
      end

      seas = season date
      rank = Ranks::FERIAL
      if date.sunday?
        rank = Ranks::SUNDAY_UNPRIVILEGED
        if [Seasons::ADVENT, Seasons::LENT, Seasons::EASTER].include?(seas)
          rank = Ranks::PRIMARY
        end
      else
        case seas
        when Seasons::LENT
          rank = Ranks::FERIAL_PRIVILEGED
        when Seasons::ADVENT
          if date >= Date.new(@year, 12, 17)
            rank = Ranks::FERIAL_PRIVILEGED
          end
        end
      end

      colour = SEASON_COLOUR[seas]

      return Celebration.new '', rank, colour
    end

    # helper: difference between two Dates in days
    def date_difference(d1, d2)
      return (d1 - d2).numerator
    end
  end
end
