module CalendariumRomanum
  class Rank
    include Comparable

    def initialize(priority = nil, desc = nil, short_desc = nil)
      @priority = priority
      @desc = desc
      @short_desc = short_desc
    end

    attr_reader :priority
    alias to_f priority

    def desc
      @desc && I18n.t(@desc)
    end

    alias to_s desc

    def short_desc
      @short_desc && I18n.t(@short_desc)
    end

    def <=>(other)
      other.priority <=> priority
    end

    def solemnity?
      priority.to_i == 1
    end

    def feast?
      priority.to_i == 2
    end

    def memorial?
      priority.to_i == 3 && priority <= 3.12
    end
  end
end
