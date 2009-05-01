# Install I18n exception handler only in Production mode
if Rails.env == 'production'
  I18n.exception_handler = :default_translation
end
