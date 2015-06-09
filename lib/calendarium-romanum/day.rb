

module CalendariumRomanum
  
  # information on one particular day of the liturgical year
  class Day
    def initialize(**args)
      %i(date season celebrations).each do |a|
        if args.include? a
          instance_variable_set "@#{a}", args[a]
        end
      end
    end

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

    attr_reader :title

    attr_reader :colour
  end

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
