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

    def solemnity?
      priority.to_i == 1
    end

    def feast?
      priority.to_i == 2
    end

    def memorial?
      priority.to_i == 3
    end
  end

  # ranks of celebrations
  module Ranks
    # Values are at the same time references to sections
    # of the Table of Liturgical Days.
    # The lower value, the higher rank.
    TRIDUUM           = Rank.new 1.1, I18n.t('rank.1_1')
    PRIMARY           = Rank.new 1.2, I18n.t('rank.1_2') # description may not be exact
    SOLEMNITY_GENERAL = Rank.new 1.3, I18n.t('rank.1_3'), I18n.t('rank.short.solemnity') # description may not be exact
    SOLEMNITY_PROPER  = Rank.new 1.4, I18n.t('rank.1_4'), I18n.t('rank.short.solemnity')

    FEAST_LORD_GENERAL  = Rank.new 2.5, I18n.t('rank.2_5'), I18n.t('rank.short.feast')
    SUNDAY_UNPRIVILEGED = Rank.new 2.6, I18n.t('rank.2_6')
    FEAST_GENERAL       = Rank.new 2.7, I18n.t('rank.2_7'), I18n.t('rank.short.feast')
    FEAST_PROPER        = Rank.new 2.8, I18n.t('rank.2_8'), I18n.t('rank.short.feast')
    FERIAL_PRIVILEGED   = Rank.new 2.9, I18n.t('rank.2_9')

    MEMORIAL_GENERAL  = Rank.new 3.10, I18n.t('rank.3_10'), I18n.t('rank.short.memorial')
    MEMORIAL_PROPER   = Rank.new 3.11, I18n.t('rank.3_11'), I18n.t('rank.short.memorial')
    MEMORIAL_OPTIONAL = Rank.new 3.12, I18n.t('rank.3_12'), I18n.t('rank.short.memorial_opt')
    FERIAL            = Rank.new 3.13, I18n.t('rank.3_13'), I18n.t('rank.short.ferial')

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
