class TreeNode < ActiveRecord::Base
    has_and_belongs_to_many :labels
    belongs_to :workarea
    belongs_to :user

    acts_as_tree :order => "tn_order"
end
