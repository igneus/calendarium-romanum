%w(
  version
  i18n_setup
  rank
  enum
  enums
  errors
  data
  day
  calendar
  perpetual_calendar
  temporale/dates
  temporale/celebration_factory
  temporale/extensions/christ_eternal_priest
  temporale
  sanctorale
  sanctoraleloader
  sanctorale_factory
  transfers
  abstract_date
  util
  ordinalizer
).each do |f|
  require_relative File.join('calendarium-romanum', f)
end
