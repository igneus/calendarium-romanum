
%w{
calendar
temporale
day
}.each do |f| 
  require_relative File.join('calendarium-romanum', f) 
end
