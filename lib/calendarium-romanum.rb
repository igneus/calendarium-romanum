%w{
enums
calendar
temporale
sanctorale
sanctoraleloader
day
util
}.each do |f| 
  require_relative File.join('calendarium-romanum', f) 
end
