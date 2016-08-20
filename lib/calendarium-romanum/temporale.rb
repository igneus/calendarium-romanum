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
    def initialize(year=nil)
      @year = year
      prepare_solemnities unless @year.nil?
    end

    class << self
      # Determines liturgical year for the given date
      def liturgical_year(date)
        year = date.year
        temporale = Temporale.new year

        if date < temporale.first_advent_sunday
          return year - 1
        end

        return year
      end

      # creates a Calendar for the liturgical year including given
      # date
      def for_day(date)
        return new(liturgical_year(date))
      end
    end

    def start_date(year=nil)
      first_advent_sunday(year)
    end

    def end_date(year=nil)
      year ||= @year
      first_advent_sunday(year+1) - 1
    end

    def date_range(year=nil)
      start_date(year) .. end_date(year)
    end

    def range_check(date)
      unless date_range.include? date
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

    def octave_of(date)
      date + WEEK
    end

    WEEKDAYS = %w{sunday monday tuesday wednesday thursday friday saturday}
    WEEKDAYS.each_with_index do |weekday, weekday_i|
      define_method "#{weekday}_before" do |date|
        send('weekday_before', weekday_i, date)
      end

      define_method "#{weekday}_after" do |date|
        send('weekday_after', weekday_i, date)
      end
    end

    # first_advent_sunday -> advent_sunday(1)
    %w{first second third fourth}.each_with_index do |word,i|
      define_method "#{word}_advent_sunday" do |year=nil|
        send("advent_sunday", i + 1, year)
      end
    end

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

    def holy_family(year=nil)
      sunday_after(nativity(year))
    end

    def mother_of_god(year=nil)
      octave_of(nativity(year))
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

    def good_friday(year=nil)
      return friday_before(easter_sunday(year))
    end

    def holy_saturday(year=nil)
      return saturday_before(easter_sunday(year))
    end

    def pentecost(year=nil)
      year ||= @year
      return easter_sunday(year) + 7 * WEEK
    end

    def holy_trinity(year=nil)
      sunday_after(pentecost(year))
    end

    def body_blood(year=nil)
      thursday_after(holy_trinity(year))
    end

    def sacred_heart(year=nil)
      friday_after(sunday_after(body_blood(year)))
    end

    def christ_king(year=nil)
      year ||= @year
      sunday_before(first_advent_sunday(year + 1))
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

    # returns a Celebration
    # scheduled for the given day
    #
    # expected arguments: Date or two Integers (month, day)
    def get(*args)
      if args.size == 1 && args[0].is_a?(Date)
        date = args[0]
      else
        month, day = args
        date = Date.new @year, month, day
        unless date_range.include? date
          date = Date.new @year + 1, month, day
        end
      end

      return solemnity(date) || sunday(date) || ferial(date)
    end

    private

    # the celebration determination split in methods:

    def solemnity(date)
      if @solemnities.has_key?(date)
        return @solemnities[date]
      end

      seas = season(date)
      case seas
      when Seasons::EASTER
        if date <= sunday_after(easter_sunday)
          return Celebration.new '', Ranks::PRIMARY, SEASON_COLOUR[seas]
        end
      end

      return nil
    end

    def sunday(date)
      return nil unless date.sunday?

      seas = season date
      rank = Ranks::SUNDAY_UNPRIVILEGED
      if [Seasons::ADVENT, Seasons::LENT, Seasons::EASTER].include?(seas)
        rank = Ranks::PRIMARY
      end

      return Celebration.new '', rank, SEASON_COLOUR[seas]
    end

    def ferial(date)
      seas = season date
      rank = Ranks::FERIAL
      case seas
      when Seasons::ADVENT
        if date >= Date.new(@year, 12, 17)
          rank = Ranks::FERIAL_PRIVILEGED
        end
      when Seasons::CHRISTMAS
        if date < mother_of_god
          rank = Ranks::FERIAL_PRIVILEGED
        end
      when Seasons::LENT
        rank = Ranks::FERIAL_PRIVILEGED
      end

      return Celebration.new '', rank, SEASON_COLOUR[seas]
    end

    # helper: difference between two Dates in days
    def date_difference(d1, d2)
      return (d1 - d2).numerator
    end

    # prepare dates of temporale solemnities and their octaves
    def prepare_solemnities
      @solemnities = {}

      {
        nativity: ['The Nativity of the Lord', nil, nil],
        holy_family: ['The Holy Family of Jesus, Mary and Joseph', Ranks::PRIMARY, nil],
        epiphany: ['The Epiphany of the Lord', nil, nil],
        baptism_of_lord: ['The Baptism of the Lord', Ranks::FEAST_LORD_GENERAL, nil],
        good_friday: ['Friday of the Passion of the Lord', Ranks::TRIDUUM, Colours::RED],
        holy_saturday: ['Holy Saturday', Ranks::TRIDUUM, nil],
        easter_sunday: ['Easter Sunday of the Resurrection of the Lord', Ranks::TRIDUUM, nil],
        pentecost: ['Pentecost Sunday', nil, Colours::RED],
        holy_trinity: ['The Most Holy Trinity', Ranks::SOLEMNITY_GENERAL, Colours::WHITE],
        body_blood: ['The Most Holy Body and Blood of Christ', Ranks::SOLEMNITY_GENERAL, Colours::WHITE],
        sacred_heart: ['The Most Sacred Heart of Jesus', Ranks::SOLEMNITY_GENERAL, Colours::WHITE],
        christ_king: ['Our Lord Jesus Christ, King of the Universe', Ranks::SOLEMNITY_GENERAL, Colours::WHITE],
      }.each_pair do |method_name, data|
        date = send(method_name)
        title, rank, colour = data
        @solemnities[date] = Celebration.new(
                                             title,
                                             rank || Ranks::PRIMARY,
                                             colour || SEASON_COLOUR[season(date)]
                                            )
      end
    end
  end
end
