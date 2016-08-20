module CalendariumRomanum

  # Resolves transfers of solemnities.
  class Transfers
    def initialize(temporale, sanctorale)
      @transferred = {}

      dates = sanctorale.solemnities.keys.collect do |abstract_date|
        temporale.concretize_abstract_date abstract_date
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
        end until valid_destination?(transfer_to, temporale, sanctorale)
        @transferred[transfer_to] = loser
      end
    end

    def get(date)
      @transferred[date]
    end

    private

    def valid_destination?(day, temporale, sanctorale)
      return false if temporale.get(day).rank >= FEAST_PROPER

      sc = sanctorale.get(day)
      return false if sc.size > 0 && sc.first.rank >= FEAST_PROPER

      true
    end
  end
end
