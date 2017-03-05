module CalendariumRomanum
  class Rank
    include Comparable

    @@instances = {}

    def initialize(priority=nil, desc=nil, short_desc=nil)
      @priority = priority
      @desc = desc
      @short_desc = short_desc

      @@instances[self.priority] = self
    end

    attr_reader :priority
    alias_method :to_f, :priority

    def desc
      @desc && I18n.t(@desc)
    end

    alias_method :to_s, :desc

    def short_desc
      @short_desc && I18n.t(@short_desc)
    end

    def <=>(b)
      b.priority <=> self.priority
    end

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
end
