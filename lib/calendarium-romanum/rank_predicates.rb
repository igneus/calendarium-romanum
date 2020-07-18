module CalendariumRomanum
  # Mixin providing rank-describing predicates.
  # Expects the including class to have instance method +#rank+ returning a {Rank}.
  module RankPredicates
    # @return [Boolean]
    def solemnity?
      rank.priority.to_i == 1
    end

    # @return [Boolean]
    # @since 0.6.0
    def sunday?
      rank == Ranks::SUNDAY_UNPRIVILEGED
    end

    # @return [Boolean]
    def feast?
      rank.priority.to_i == 2
    end

    # @return [Boolean]
    def memorial?
      rank.priority.to_i == 3 && rank.priority <= 3.12
    end

    # @return [Boolean]
    def optional_memorial?
      rank == Ranks::MEMORIAL_OPTIONAL
    end

    # @return [Boolean]
    def obligatory_memorial?
      memorial? && !optional_memorial?
    end

    # @return [Boolean]
    # @since 0.6.0
    def ferial?
      rank == Ranks::FERIAL ||
        rank == Ranks::FERIAL_PRIVILEGED
    end
  end
end
