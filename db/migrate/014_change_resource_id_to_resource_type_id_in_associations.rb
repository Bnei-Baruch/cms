class ChangeResourceIdToResourceTypeIdInAssociations < ActiveRecord::Migration
  def self.up
		rename_column(:associations, :resource_id, :resource_type_id)
  end

  def self.down
		rename_column(:associations, :resource_type_id, :resource_id)
  end
end
