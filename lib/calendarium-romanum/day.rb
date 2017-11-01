require 'forwardable'

module CalendariumRomanum

  # information on one particular day of the liturgical year
  class Day
    def initialize(date: nil, season: nil, season_week: nil, celebrations: nil, vespers: nil)
      @date = date
      @season = season
      @season_week = season_week
      @celebrations = celebrations ? celebrations.dup : []
      @vespers = vespers
    end

    def succ
      Day.new(@date + 1, @season, @season_week, @celebrations, @vespers)
    end
    attr_reader :date

    def weekday
      date.wday
    end

    # one of the Seasons (Symbol)
    attr_reader :season

    # week of the season (Integer)
    attr_reader :season_week

    # an Array of Celebrations, possibly empty
    attr_reader :celebrations

    # nil or Celebration from which first Vespers are celebrated
    # instead of Vespers of the day's other Celebrations.
    # Please note that Calendar by default *doesn't* populate
    # Vespers, - it's an opt-in feature.
    attr_reader :vespers

    def ==(other)
      self.class == other.class &&
        date == other.date &&
        season == other.season &&
        season_week == other.season_week &&
        celebrations == other.celebrations &&
        vespers == other.vespers
    end

    # Are the day's Vespers suppressed in favour of first Vespers
    # of a Sunday or solemnity?
    def vespers_from_following?
      !vespers.nil?
    end
  end

  # information on one particular celebration of the liturgical year
  # (like a Sunday, feast or memorial);
  # some days have no (ferial office is used), some have one,
  # some have more among which one may and may not be chosen
  class Celebration
    extend Forwardable

    def initialize(title = '', rank = Ranks::FERIAL, colour = Colours::GREEN, symbol = nil)
      @title = title
      @rank = rank
      @colour = colour
      @symbol = symbol
    end

    attr_reader :rank
    def_delegators :@rank, :solemnity?, :feast?, :memorial?

    def title
      if @title.respond_to? :call
        @title.call
      else
        @title
      end
    end

    attr_reader :colour
    alias color colour

    attr_reader :symbol

    def ==(other)
      self.class == other.class &&
        title == other.title &&
        rank == other.rank &&
        colour == other.colour
    end

    def change(title: nil, rank: nil, colour: nil, color: nil, symbol: nil)
      self.class.new(
        title || self.title,
        rank || self.rank,
        colour || color || self.colour,
        symbol || self.symbol
      )
    end
  end
end
