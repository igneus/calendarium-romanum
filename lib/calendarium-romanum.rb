# Module wrapping the gem's classes
#
# If you hate typing the long module name, see {CR}
module CalendariumRomanum
end

require 'date'

%w(
  version
  i18n_setup
  abstract_date
  rank_predicates
  rank
  enum
  enums
  errors
  data
  day
  calendar
  perpetual_calendar
  base_temporale
  temporale/celebration_factory
  temporale/date_helper
  temporale/dates
  temporale
  temporale/easter_table
  temporale/extensions
  temporale/extensions/christ_eternal_priest
  temporale/extensions/dedication_before_all_saints
  sanctorale
  sanctorale_loader
  sanctorale_writer
  sanctorale_factory
  transfers
  util
  ordinalizer
).each do |f|
  require_relative File.join('calendarium-romanum', f)
end
