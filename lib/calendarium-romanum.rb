%w{
version
i18n_setup
rank
enum
enums
data
calendar
temporale
temporale/dates
temporale/extensions/christ_eternal_priest
sanctorale
sanctoraleloader
sanctorale_factory
transfers
day
abstract_date
util
ordinalizer
}.each do |f| 
  require_relative File.join('calendarium-romanum', f) 
end
