class DatesSchedule < Kabtv
    set_table_name "dates"

    def self.get_day(lang, day)
        find(:all,
            :conditions => 'lang =\'' + lang + '\' AND week_day = \'' + day + '\''
            )
    end
end
