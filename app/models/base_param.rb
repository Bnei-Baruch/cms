class BaseParam < Kabtv
  def self.enabled(lang)
    base = find_by_lang_and_is_hidden(lang, 0)
    base.enable_messages == 1 rescue false
  end
end
