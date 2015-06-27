module CalendariumRomanum

  module Seasons
    ADVENT = :advent
    CHRISTMAS = :christmas
    LENT = :lent
    EASTER = :easter
    ORDINARY = :ordinary
    # is Triduum Sacrum a special season? For now I count Friday and Saturday
    # to the Lent, Sunday to the Easter time
  end

  LECTIONARY_CYCLES = [:A, :B, :C]

  class Rank < Struct.new(:priority, :desc, :short_desc)
    include Comparable

    @@instances = {}

    def initialize(*args)
      super(*args)

      @@instances[self.priority] = self
    end

    def <=>(b)
      b.priority <=> self.priority
    end

    alias_method :to_f, :priority
    alias_method :to_s, :desc

    def self.[](priority)
      @@instances[priority]
    end
  end

  # ranks of celebrations
  module Ranks
    # Values are at the same time references to sections
    # of the Table of Liturgical Days.
    # The lower value, the higher rank.
    TRIDUUM           = Rank.new 1.1, 'Easter triduum'
    PRIMARY           = Rank.new 1.2, 'Primary liturgical days' # description may not be exact
    SOLEMNITY_GENERAL = Rank.new 1.3, 'Solemnities in the General Calendar', 'solemnity' # description may not be exact
    SOLEMNITY_PROPER  = Rank.new 1.4, 'Proper solemnities', 'solemnity'

    FEAST_LORD_GENERAL  = Rank.new 2.5, 'Feasts of the Lord in the General Calendar', 'feast'
    SUNDAY_UNPRIVILEGED = Rank.new 2.6, 'Unprivileged Sundays'
    FEAST_GENERAL       = Rank.new 2.7, 'Feasts of saints in the General Calendar', 'feast'
    FEAST_PROPER        = Rank.new 2.8, 'Proper feasts', 'feast'
    FERIAL_PRIVILEGED   = Rank.new 2.9, 'Privileged ferials'

    MEMORIAL_GENERAL  = Rank.new 3.10, 'Obligatory memorials in the General Calendar', 'memorial'
    MEMORIAL_PROPER   = Rank.new 3.11, 'Proper obligatory memorials', 'memorial'
    MEMORIAL_OPTIONAL = Rank.new 3.12, 'Optional memorials', 'optional memorial'
    FERIAL            = Rank.new 3.13, 'Unprivileged ferials', 'ferial'

    def self.[](priority)
      Rank[priority]
    end
  end

  module Colours
    GREEN = :green
    VIOLET = :violet
    WHITE = :white
    RED = :red
  end

  Colors = Colours
end
