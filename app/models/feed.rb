class Feed < ActiveRecord::Base
  belongs_to :tree_node, :foreign_key => :section_id
end
