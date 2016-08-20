# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'calendarium-romanum'
  s.version     = '0.0.0'
  # s.date        = '2014-07-20'
  s.summary     = 'Roman Catholic liturgical calendar computations'

  s.description = File.read 'README.md'

  s.authors     = ['Jakub Pavlík']
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = (Dir['bin/*'] + Dir['lib/*.rb'] + Dir['lib/*/*.rb'] +
                   Dir['spec/*.rb'])
  s.executables = []
  s.homepage    = 'http://github.com/igneus/calendarium-romanum'
  s.licenses    = ['LGPL-3.0', 'MIT']

  s.add_development_dependency 'rspec', '~> 2.14'
end
