module CalendariumRomanum
  # Celebration rank
  class Rank
    include Comparable

    # @param priority [Float, nil] number in the Table of Liturgical Days
    # @param desc [String, nil]
    #   full description (translation string identifier)
    # @param short_desc [String, nil]
    #   short rank name (translation string identifier)
    def initialize(priority = nil, desc = nil, short_desc = nil)
      @priority = priority
      @desc = desc
      @short_desc = short_desc
    end

    # @return [Float, nil]
    attr_reader :priority
    alias to_f priority

    # Full description - internationalized human-readable string.
    #
    # @return [String, nil]
    def desc
      @desc && I18n.t(@desc)
    end

    # String representation mostly for debugging purposes.
    #
    # @return [String]
    def to_s
      # 'desc' instead of '@desc' is intentional -
      # for a good reason we don't present contents of an instance
      # variable but result of an instance method
      "#<#{self.class.name} @priority=#{priority} desc=#{desc.inspect}>"
    end

    # Short name - internationalized human-readable string.
    #
    # @return [String, nil]
    def short_desc
      @short_desc && I18n.t(@short_desc)
    end

    def <=>(other)
      other.priority <=> priority
    end

    # @return [Boolean]
    def solemnity?
      priority.to_i == 1
    end

    # @return [Boolean]
    # @since 0.6.0
    def sunday?
      self == Ranks::SUNDAY_UNPRIVILEGED
    end

    # @return [Boolean]
    def feast?
      priority.to_i == 2
    end

    # @return [Boolean]
    def memorial?
      priority.to_i == 3 && priority <= 3.12
    end

    # @return [Boolean]
    # @since 0.6.0
    def ferial?
      self == Ranks::FERIAL ||
        self == Ranks::FERIAL_PRIVILEGED
    end
  end
end
