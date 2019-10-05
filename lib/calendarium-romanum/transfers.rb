module CalendariumRomanum

  # {Calendar} component.
  # Resolves transfers of conflicting solemnities.
  #
  # For any day {Temporale} has a {Celebration}.
  # Often {Sanctorale} has one (or more), too.
  # {Calendar} handles these conflicts, in most cases
  # by throwing away all the proposed {Celebration}s except
  # of the one of highest rank.
  # But when there are two conflicting _solemnities_,
  # one is celebrated on the given day and the less lucky one
  # must be transferred to another day.
  # However, not all days are valid as targets of solemnity transfer.
  class Transfers
    # @param temporale [Temporale]
    # @param sanctorale [Sanctorale]
    def initialize(temporale, sanctorale)
      @transferred = {}
      @temporale = temporale
      @sanctorale = sanctorale

      dates = sanctorale.solemnities.keys.collect do |abstract_date|
        concretize_abstract_date abstract_date
      end.sort

      dates.each do |date|
        tc = temporale.get(date)
        next unless tc.solemnity?

        sc = sanctorale.get(date)
        next unless sc.size == 1 && sc.first.solemnity?

        loser = [tc, sc.first].sort_by(&:rank).first

        transfer_to = date
        begin
          transfer_to = transfer_to.succ
        end until valid_destination?(transfer_to)
        @transferred[transfer_to] = loser
      end
    end

    # Retrieve solemnity for the specified day
    #
    # @param date [Date]
    # @return [Celebration, null]
    def get(date)
      @transferred[date]
    end

    private

    def valid_destination?(day)
      return false if @temporale.get(day).rank >= Ranks::FEAST_PROPER

      sc = @sanctorale.get(day)
      return false if sc.size > 0 && sc.first.rank >= Ranks::FEAST_PROPER

      true
    end

    # Converts an AbstractDate to a Date in the given
    # liturgical year.
    # It isn't guaranteed to work well (and probably doesn't work well)
    # for the grey zone of dates between earliest and latest
    # possible date of the first Advent Sunday, but that's no problem
    # as long as there are no sanctorale solemnities in this
    # date range.
    def concretize_abstract_date(abstract_date)
      d = abstract_date.concretize(@temporale.year + 1)
      if @temporale.date_range.include? d
        d
      else
        abstract_date.concretize(@temporale.year)
      end
    end
  end
end
