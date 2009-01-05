module I18n
  # Smart Exception handler for I18n
  # If the word doesn't have translation in this locale
  # but is String -- return it as is. If it is Symbol, then return a humanized version
  def I18n.smart_exception(e, locale, word, *args)
    if word.is_a?(Symbol)
      return ActiveSupport::Inflector.humanize(word)
    elsif word.is_a?(String)
      return word
    else
      return word.class.to_s
    end
  end
end

# Install I18n exception handler only in Production mode
if Rails.env == 'production'
  I18n.exception_handler = :smart_exception
end
