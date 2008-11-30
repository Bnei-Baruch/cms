class Question < Kabtv
    def self.approved_questions
        find(:all,
            :conditions => '(isquestion = 1) AND (lang!=\'Russian\') AND (is_hidden=0 OR is_hidden IS NULL) AND (approved <> 0)',
            :order => 'id DESC')
    end
end
