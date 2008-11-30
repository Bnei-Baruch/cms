class Listing < Kabtv
    set_table_name "listing"

    def self.get_day(lang, day)
        find(:all,
            :conditions => 'lang =\'' + lang + '\' AND week_day = \'' + day + '\'',
            :order => 'start_time')
    end
end
