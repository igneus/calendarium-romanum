### i18n

appraise 'i18n-0.9' do
  gem 'i18n', '0.9.5'
end

appraise 'i18n-1.0' do
  gem 'i18n', '1.0.0'
end

appraise 'i18n-1.8' do
  gem 'i18n', '1.8.9'
end

### thor

appraise 'thor-0.15' do
  gem 'thor', '0.15.0'
end

appraise 'thor-0.16' do
  gem 'thor', '0.15.0'
end

appraise 'thor-0.17' do
  gem 'thor', '0.17.0'
end

appraise 'thor-0.18' do
  gem 'thor', '0.18.1'
end

appraise 'thor-0.19' do
  gem 'thor', '0.19.4'
end

appraise 'thor-0.20' do
  gem 'thor', '0.20.3'
end

# thor >= 1.0 isn't compatible with our version of aruba; CLI specs are broken,
#   but the CLI itself works well, as can be tested by
#   `bundle exec appraisal thor-1.1 ruby -Ilib bin/calendariumrom ...`

# ruby >= 2.4 required
appraise 'thor-1.0' do
  gem 'thor', '1.0.1'

  group :test do
    gem 'aruba', '1.0.0'
    gem 'cucumber', '3.0.0'
  end
end

# ruby >= 2.4 required
appraise 'thor-1.1' do
  gem 'thor', '1.1.0'

  group :test do
    gem 'aruba', '1.0.0'
    gem 'cucumber', '3.0.0'
  end
end
