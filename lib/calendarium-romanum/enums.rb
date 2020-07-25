module CalendariumRomanum
  # Methods shared by most value objects defined by the gem
  module ValueObjectInterface
    # Machine-readable internal representation of the value
    #
    # @return [Symbol]
    attr_reader :symbol
    alias to_sym symbol

    # Internationalized, human-readable name
    #
    # @return [String]
    def name
      I18n.t @i18n_key
    end

    # String representation of the contents for debugging purposes
    #
    # @return [String]
    def to_s
      "#<#{self.class.name} #{symbol}>"
    end
  end

  # Represents a liturgical colour
  class Colour
    include ValueObjectInterface

    def initialize(symbol)
      @symbol = symbol
      @i18n_key = "colour.#{@symbol}"
    end
  end

  # Standard set of liturgical colours
  class Colours < Enum
    GREEN = Colour.new(:green)
    VIOLET = Colour.new(:violet)
    WHITE = Colour.new(:white)
    RED = Colour.new(:red)

    values(index_by: :symbol) do
      [
        GREEN,
        VIOLET,
        WHITE,
        RED
      ]
    end
  end

  # Convenience alias (American English spelling)
  Colors = Colours

  # Liturgical season
  class Season
    include ValueObjectInterface

    # @param symbol [Symbol] internal identifier
    # @param colour [Colour]
    #   liturgical colour of the season's Sundays and ferials
    def initialize(symbol, colour)
      @symbol = symbol
      @colour = colour
      @i18n_key = "temporale.season.#{@symbol}"
    end

    # Liturgical colour of the season's Sundays and ferials
    #
    # @return [Colour]
    attr_reader :colour
  end

  # Standard set of liturgical seasons
  class Seasons < Enum
    ADVENT = Season.new(:advent, Colours::VIOLET)
    CHRISTMAS = Season.new(:christmas, Colours::WHITE)
    LENT = Season.new(:lent, Colours::VIOLET)
    EASTER = Season.new(:easter, Colours::WHITE)
    ORDINARY = Season.new(:ordinary, Colours::GREEN)

    values(index_by: :symbol) do
      [
        ADVENT,
        CHRISTMAS,
        LENT,
        EASTER,
        ORDINARY,
      ]
    end
  end

  # Celebration ranks as specified in the Table of Liturgical Days
  class Ranks < Enum
    TRIDUUM           = Rank.new(1.1, 'rank.1_1')
    PRIMARY           = Rank.new(1.2, 'rank.1_2') # description may not be exact
    SOLEMNITY_GENERAL = Rank.new(1.3, 'rank.1_3', 'rank.short.solemnity') # description may not be exact
    SOLEMNITY_PROPER  = Rank.new(1.4, 'rank.1_4', 'rank.short.solemnity')

    FEAST_LORD_GENERAL  = Rank.new(2.5, 'rank.2_5', 'rank.short.feast')
    SUNDAY_UNPRIVILEGED = Rank.new(2.6, 'rank.2_6', 'rank.short.sunday')
    FEAST_GENERAL       = Rank.new(2.7, 'rank.2_7', 'rank.short.feast')
    FEAST_PROPER        = Rank.new(2.8, 'rank.2_8', 'rank.short.feast')
    FERIAL_PRIVILEGED   = Rank.new(2.9, 'rank.2_9', 'rank.short.ferial')

    MEMORIAL_GENERAL  = Rank.new(3.10, 'rank.3_10', 'rank.short.memorial')
    MEMORIAL_PROPER   = Rank.new(3.11, 'rank.3_11', 'rank.short.memorial')
    MEMORIAL_OPTIONAL = Rank.new(3.12, 'rank.3_12', 'rank.short.memorial_opt')
    FERIAL            = Rank.new(3.13, 'rank.3_13', 'rank.short.ferial')
    # Not included as a celebration rank on it's own
    # in the Table of Liturgical Days
    COMMEMORATION     = Rank.new(4.0,  'rank.4_0', 'rank.short.commemoration')

    values(index_by: :priority) do
      # Values are at the same time references to sections
      # of the Table of Liturgical Days.
      # The lower value, the higher rank.
      [
        TRIDUUM,
        PRIMARY,
        SOLEMNITY_GENERAL,
        SOLEMNITY_PROPER,

        FEAST_LORD_GENERAL,
        SUNDAY_UNPRIVILEGED,
        FEAST_GENERAL,
        FEAST_PROPER,
        FERIAL_PRIVILEGED,

        MEMORIAL_GENERAL,
        MEMORIAL_PROPER,
        MEMORIAL_OPTIONAL,
        FERIAL,

        COMMEMORATION,
      ]
    end
  end
end
