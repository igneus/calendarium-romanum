# What liturgical season is it today?

require 'calendarium-romanum'

season = CalendariumRomanum::Temporale.for_day(Date.today).season(Date.today)
puts season
