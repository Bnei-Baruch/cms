class Description < ActiveRecord::Base
  belongs_to :item
  belongs_to :label
end
