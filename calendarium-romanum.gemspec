# -*- coding: utf-8 -*-
require_relative 'lib/calendarium-romanum/version'

Gem::Specification.new do |s|
  s.name        = 'calendarium-romanum'
  s.version     = CalendariumRomanum::VERSION
  s.date        = CalendariumRomanum::RELEASE_DATE.to_s
  s.summary     = 'Roman Catholic liturgical calendar computations'

  s.description = 'calendar computations according to the Roman Catholic liturgical calendar as instituted by MP Mysterii Paschalis of Paul VI (1969).'

  s.authors     = ['Jakub Pavlík']
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = %w(lib/**/*.rb data/* spec/*.rb config/**/*)
                  .collect {|glob| Dir[glob] }
                  .flatten
                  .reject {|path| path.end_with? '~' } # Emacs backups
  s.executables = %w(calendariumrom)
  s.homepage    = 'http://github.com/igneus/calendarium-romanum'
  s.licenses    = ['LGPL-3.0', 'MIT']

  s.add_dependency 'thor', '~> 0.18'
  s.add_dependency 'i18n', '~> 0.6'
  s.add_dependency 'roman-numerals', '~> 0.3'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'aruba', '~> 0.8'
  # We don't use cucumber, but it is required by aruba
  # and cucumber >= 3.0.0 requires ruby >= 2.1,
  # but we want the tests to pass on ruby 2.0 as earliest target
  s.add_development_dependency 'cucumber', '~>2.99'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'rubocop', '~> 0.46'
end
