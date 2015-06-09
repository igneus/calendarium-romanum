module CalendariumRomanum

  module Seasons
    ADVENT = :advent
    CHRISTMAS = :christmas
    LENT = :lent
    EASTER = :easter
    ORDINARY = :ordinary
    # is Triduum Sacrum a special season? For now I count Friday and Saturday
    # to the Lent, Sunday to the Easter time
  end

  LECTIONARY_CYCLES = [:A, :B, :C]
end
