class Language < Kabtv
    def self.get_url(language)
        language = find_by_lang(language)
        language.bitrate1_url || language.video_url rescue ""
    end
end
