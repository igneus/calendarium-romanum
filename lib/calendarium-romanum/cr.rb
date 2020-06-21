require 'calendarium-romanum'

# The module name {CalendariumRomanum} is quite long,
# hence constant +CR+ is provided as a convenient shortcut.
# It is _not_ loaded by +require 'calendarium-romanum'+,
# must be required explicitly +require 'calendarium-romanum/cr'+ -
# because there's a good chance
# that the short constant name clashes with a constant
# defined by some other code.
#
# @example
#   require 'calendarium-romanum/cr'
#
#   calendar = CR::Calendar.new 2000
# @since 0.7.0
CR = CalendariumRomanum
