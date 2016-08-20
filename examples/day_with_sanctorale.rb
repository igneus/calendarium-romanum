# day.rb only takes temporale into account. Let's load some
# sanctorale and look if it is a feast of a saint today!

require 'calendarium-romanum'

DEFAULT_SANCTORALE = File.expand_path '../data/universal-en.txt', File.dirname(__FILE__)

sanctorale = CalendariumRomanum::Sanctorale.new
sanctorale_file = ARGV[0] || DEFAULT_SANCTORALE
loader = CalendariumRomanum::SanctoraleLoader.new
loader.load_from_file sanctorale, sanctorale_file

calendar = CalendariumRomanum::Calendar.for_day(Date.today, sanctorale)

day = calendar.day(Date.today)
p day
