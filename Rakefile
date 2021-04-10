require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc 'Run specs with each fully supported locale'
task :spec_all_locales do
  %w(en la cs fr it pt).each do |locale|
    sh "LOCALE=#{locale} rake spec"
  end
end

desc 'Generates calendar dumps for regression tests anew'
task :regression_refresh do
  2020.upto(2030).each do |year|
    sh "ruby -Ilib bin/calendariumrom dump #{year} > spec/regression_dumps/#{year}.txt"
  end
end
