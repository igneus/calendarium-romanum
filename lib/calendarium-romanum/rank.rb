module CalendariumRomanum
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
end
