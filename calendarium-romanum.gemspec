# -*- coding: utf-8 -*-
require_relative 'lib/calendarium-romanum/version'

Gem::Specification.new do |s|
  s.name        = 'calendarium-romanum'
  s.version     = CalendariumRomanum::VERSION
  s.date        = CalendariumRomanum::RELEASE_DATE.to_s
  s.summary     = 'Roman Catholic liturgical calendar computations'

  s.description = 'calendar computations according to the Roman Catholic liturgical calendar as instituted by MP Mysterii Paschalis of Paul VI (1969) and defined in General Norms for the Liturgical Year and the Calendar and other documents of liturgical legislation.'

  s.authors     = ['Jakub Pavlík']
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.executables = %w(calendariumrom)
  s.homepage    = 'http://github.com/igneus/calendarium-romanum'
  s.licenses    = ['LGPL-3.0', 'MIT']
  s.metadata = {
    'documentation_uri' => 'https://www.rubydoc.info/gems/calendarium-romanum/',
  }

  s.required_ruby_version = '>= 2.0'

  s.add_dependency 'thor', '~> 0.18'
  s.add_dependency 'i18n', '~> 0.6'
  s.add_dependency 'roman-numerals', '~> 0.3'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.5'
end
