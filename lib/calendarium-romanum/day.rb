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

    attr_reader :date

    def weekday
      date.wday
    end

    def weekday_name
      I18n.t(date.wday, scope: 'weekday')
    end

    # one of the Seasons
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
  # some days have one,
  # some have more among which one is to be chosen
  class Celebration
    extend Forwardable

    def initialize(title = '', rank = Ranks::FERIAL, colour = Colours::GREEN, symbol = nil, date = nil, cycle = :sanctorale)
      @title = title
      @rank = rank
      @colour = colour
      @symbol = symbol
      @date = date
      @cycle = cycle
    end

    # Rank instance
    attr_reader :rank

    def_delegators :@rank, :solemnity?, :feast?, :memorial?, :sunday?, :ferial?

    def title
      if @title.respond_to? :call
        @title.call
      else
        @title
      end
    end

    # Colour instance (always set) - liturgical colour
    attr_reader :colour
    alias color colour

    # Symbol uniquely identifying the celebration (may be nil)
    attr_reader :symbol

    # AbstractDate instance - usual date of the celebration.
    # Only set for celebrations with fixed date.
    attr_reader :date

    # Symbol :temporale|:sanctorale
    # Describes the celebration as belonging either to the
    # temporale or sanctorale cycle
    attr_reader :cycle

    def ==(b)
      self.class == b.class &&
        title == b.title &&
        rank == b.rank &&
        colour == b.colour &&
        symbol == b.symbol &&
        date == b.date &&
        cycle == b.cycle
    end

    def temporale?
      cycle == :temporale
    end

    def sanctorale?
      cycle == :sanctorale
    end

    def change(title: nil, rank: nil, colour: nil, color: nil, symbol: nil, date: nil, cycle: nil)
      self.class.new(
        title || self.title,
        rank || self.rank,
        colour || color || self.colour,
        symbol || self.symbol,
        date || self.date,
        cycle || self.cycle,
      )
    end
  end
end
