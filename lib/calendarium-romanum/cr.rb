require 'calendarium-romanum'

# Convenience shortcut for the long module name.
# *Not* loaded by `require 'calendarium-romanum'`,
# must be required explicitly `require 'calendarium-romanum/cr'` -
# because there's a good chance
# that the short constant name clashes with a constant
# defined by some other code.
CR = CalendariumRomanum
