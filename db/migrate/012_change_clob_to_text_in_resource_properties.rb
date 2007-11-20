class ChangeClobToTextInResourceProperties < ActiveRecord::Migration
  def self.up
		rename_column(:resource_properties, :clob_value, :string_value)
  end

  def self.down
		rename_column(:resource_properties, :string_value, :clob_value)
  end
end
