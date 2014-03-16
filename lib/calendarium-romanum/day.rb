

module CalendariumRomanum
  
  # information on one particular day of the liturgical year
  class Day

    attr_reader :date 

    def weekday
      date.wday
    end

    attr_reader :season

    # an Array of Celebrations, possibly empty
    attr_reader :celebrations

    # Celebration of the following day if it has first vespers
    attr_reader :vespers
 
  end

  # information on one particular celebration of the liturgical year
  # (like a Sunday, feast or memorial);
  # some days have no (ferial office is used), some have one,
  # some have more among which one may and may not be chosen
  class Celebration

    attr_reader :rank

    attr_reader :rank_num

    attr_reader :title

    attr_reader :colour
  end

  # ranks of celebrations
  module Ranks
    # the shortcut after each constant is a reference to a section
    # of the Table of Liturgical Days
    TRIDUUM           = 10000 # I.1
    PRIMARY           =  9900 # I.2
    SOLEMNITY_GENERAL =  9800 # I.3
    SOLEMNITY_PROPER  =  9700 # I.4

    FEAST_LORD_GENERAL  = 1000 # II.5
    SUNDAY_UNPRIVILEGED = 900 # II.6
    FEAST_GENERAL       = 800 # II.7
    FEAST_PROPER        = 700 # II.8
    FERIAL_PRIVILEGED   = 600 # II.9

    MEMORIAL_GENERAL  = 100 # III.10
    MEMORIAL_PROPER   =  90 # III.11
    MEMORIAL_OPTIONAL =  80 # III.12
    FERIAL            =   1 # III.13
  end
end
