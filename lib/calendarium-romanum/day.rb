require 'forwardable'

module CalendariumRomanum

  # information on one particular day of the liturgical year
  class Day
    def initialize(args={})
      %i(date season season_week celebrations).each do |a|
        if args.include? a
          instance_variable_set "@#{a}", args.delete(a)
        end
      end

      unless args.empty?
        raise ArgumentError.new "Unexpected arguments #{args.keys.join(', ')}"
      end
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
  end

  # information on one particular celebration of the liturgical year
  # (like a Sunday, feast or memorial);
  # some days have no (ferial office is used), some have one,
  # some have more among which one may and may not be chosen
  class Celebration
    extend Forwardable

    def initialize(title='', rank=Ranks::FERIAL, colour=Colours::GREEN)
      @title = title
      @rank = rank
      @colour = colour
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
    alias_method :color, :colour
  end
end
