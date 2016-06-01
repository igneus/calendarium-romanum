# What liturgical day is it today?

require 'calendarium-romanum'

day = CalendariumRomanum::Calendar.for_day(Date.today).day(Date.today)
p day
