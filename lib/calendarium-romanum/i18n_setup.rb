require 'i18n'

I18n.config.load_path = Dir[File.expand_path('../../config/locales/*.yml', File.dirname(__FILE__))]
I18n.config.enforce_available_locales = true
