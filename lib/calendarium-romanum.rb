
%w{
calendar
temporale
sanctorale
day
enums
}.each do |f| 
  require_relative File.join('calendarium-romanum', f) 
end
