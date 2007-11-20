class ChangeTypeToAssociationTypeInAssociations < ActiveRecord::Migration
  def self.up
		rename_column(:associations, :type, :association_type)
  end

  def self.down
		rename_column(:associations, :association_type, :type)
  end
end
