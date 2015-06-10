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

  # ranks of celebrations
  module Ranks
    # Values are at the same time references to sections
    # of the Table of Liturgical Days.
    # The lower value, the higher rank.
    TRIDUUM           = 1.1
    PRIMARY           = 1.2
    SOLEMNITY_GENERAL = 1.3
    SOLEMNITY_PROPER  = 1.4

    FEAST_LORD_GENERAL  = 2.5
    SUNDAY_UNPRIVILEGED = 2.6
    FEAST_GENERAL       = 2.7
    FEAST_PROPER        = 2.8
    FERIAL_PRIVILEGED   = 2.9

    MEMORIAL_GENERAL  = 3.10
    MEMORIAL_PROPER   = 3.11
    MEMORIAL_OPTIONAL = 3.12
    FERIAL            = 3.13
  end
end
