require 'log4r'

%w{
enums
calendar
temporale
sanctorale
sanctoraleloader
day
}.each do |f| 
  require_relative File.join('calendarium-romanum', f) 
end
