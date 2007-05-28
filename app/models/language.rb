class Language < ActiveRecord::Base
  has_one :text_label, :dependent => :destroy

end
