source 'https://rubygems.org'

gem 'thor'
gem 'i18n'
gem 'roman-numerals'

group :development, :test do
  gem 'rake'
end

group :development do
  gem 'rubocop'
  gem 'yard'
end

group :test do
  gem 'rspec'
  gem 'aruba'
  # We don't use cucumber, but it is required by aruba
  # and cucumber >= 3.0.0 requires ruby >= 2.1,
  # but we want the tests to pass on ruby 2.0 as earliest target
  gem 'cucumber', '~> 2.99'
  gem 'simplecov'
end
