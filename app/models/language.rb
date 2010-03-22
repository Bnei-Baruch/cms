class Language < Kabtv
  def self.get_url(language, cookies)
    lang = find_by_lang(language)
    return unless lang
    unless cookies["tvspeed_#{language}"].empty?
      names, locs, map = Language.map(lang)
      video_url = map[cookies["tvspeed_#{language}"]]
    else
		  video_url = lang.respond_to?(:bitrate1_url) ? lang.bitrate1_url : lang.video_url
    end

		video_high_url = lang.respond_to?(:bitrate1_url) ? lang.bitrate1_url : nil
		video_med_url = lang.respond_to?(:bitrate2_url) ? lang.bitrate2_url : nil
		video_low_url = lang.respond_to?(:bitrate3_url) ? lang.bitrate3_url : nil
    idx = [video_high_url, video_med_url, video_low_url].index(video_url) || 0
    return video_url, video_high_url, video_med_url, video_low_url, idx
  end

  def self.map(lang)
		names = []
		locations = []
		map = {}

		return names, locations, map unless lang.respond_to?(:bitrate1_name)
    
		names << lang.bitrate1_name unless lang.bitrate1_name.blank?
		names << lang.bitrate2_name unless lang.bitrate2_name.blank?
		names << lang.bitrate3_name unless lang.bitrate3_name.blank?
		names << lang.bitrate4_name unless lang.bitrate4_name.blank?
		names << lang.bitrate5_name unless lang.bitrate5_name.blank?
		names << lang.bitrate6_name unless lang.bitrate6_name.blank?
		locations << lang.bitrate1_location unless lang.bitrate1_location.blank?
		locations << lang.bitrate2_location unless lang.bitrate2_location.blank?
		locations << lang.bitrate3_location unless lang.bitrate3_location.blank?
		locations << lang.bitrate4_location unless lang.bitrate4_location.blank?
		locations << lang.bitrate5_location unless lang.bitrate5_location.blank?
		locations << lang.bitrate6_location unless lang.bitrate6_location.blank?
		names.uniq!
		locations.uniq!

		names.each_with_index {|n, ni|
			locations.each_with_index {|l, li|
				case
				when n == lang.bitrate1_name && l == lang.bitrate1_location
					map["#{ni}-#{li}"] = lang.bitrate1_url
				when n == lang.bitrate2_name && l == lang.bitrate2_location
					map["#{ni}-#{li}"] = lang.bitrate2_url
				when n == lang.bitrate3_name && l == lang.bitrate3_location
					map["#{ni}-#{li}"] = lang.bitrate3_url
				when n == lang.bitrate4_name && l == lang.bitrate4_location
					map["#{ni}-#{li}"] = lang.bitrate4_url
				when n == lang.bitrate5_name && l == lang.bitrate5_location
					map["#{ni}-#{li}"] = lang.bitrate5_url
				when n == lang.bitrate6_name && l == lang.bitrate6_location
					map["#{ni}-#{li}"] = lang.bitrate6_url
				end
			}
		}

		return names, locations, map
	end

end
