class Language < Kabtv
    def self.get_url(language)
        find_by_lang(language).video_url rescue ""
    end
end
