# -*- coding: utf-8 -*-
require_relative 'lib/calendarium-romanum/version'

Gem::Specification.new do |s|
  s.name        = 'calendarium-romanum'
  s.version     = CalendariumRomanum::VERSION
  s.date        = '2016-08-20'
  s.summary     = 'Roman Catholic liturgical calendar computations'

  s.description = "calendar computations according to the Roman Catholic liturgical calendar as instituted by MP Mysterii Paschalis of Paul VI (1969)."

  s.authors     = ['Jakub Pavlík']
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = (Dir['bin/*'] + Dir['lib/*.rb'] + Dir['lib/*/*.rb'] +
                   Dir['spec/*.rb'] + Dir['config/**/*'])
  s.executables = []
  s.homepage    = 'http://github.com/igneus/calendarium-romanum'
  s.licenses    = ['LGPL-3.0', 'MIT']

  s.add_dependency 'thor', '~> 0.18'
  s.add_dependency 'i18n', '~> 0.6'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 4.2'
end
