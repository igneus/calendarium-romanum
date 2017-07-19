%w{
version
i18n_setup
rank
enum
enums
data
calendar
temporale
sanctorale
sanctoraleloader
sanctorale_factory
transfers
day
abstract_date
util
}.each do |f| 
  require_relative File.join('calendarium-romanum', f) 
end
