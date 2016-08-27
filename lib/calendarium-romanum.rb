%w{
version
enums
calendar
temporale
sanctorale
sanctoraleloader
transfers
day
abstract_date
util
}.each do |f| 
  require_relative File.join('calendarium-romanum', f) 
end
