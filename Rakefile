require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

EXECUTABLE = 'ruby -Ilib bin/calendariumrom'

desc 'Run specs with each fully supported locale'
task :spec_all_locales do
  %w(en la cs fr it pt).each do |locale|
    sh "LOCALE=#{locale} rake spec"
  end
end

desc 'Generates calendar dumps for regression tests anew'
task :regression_refresh do
  2020.upto(2030).each do |year|
    sh "#{EXECUTABLE} dump #{year} > spec/regression_dumps/#{year}.txt"
  end

  a = 2000
  b = 2100
  sh "#{EXECUTABLE} dump_transfers #{a} #{b} > spec/regression_dumps/transfers_#{a}_#{b}.txt"
end

desc 'Checks that all versions of the General Roman Calendar are the same'
task :data_cmp do
  vernacular = Dir['data/universal-*.txt'].delete_if {|f| f.end_with? '-la.txt' }

  vernacular.each do |f|
    sh "#{EXECUTABLE} cmp data/universal-la.txt #{f}"
  end
end
