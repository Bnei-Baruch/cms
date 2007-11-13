class ChangeColumnsInResourceProperties < ActiveRecord::Migration
  def self.up
		rename_column(:resource_properties, :vc_value, :string_value)
		rename_column(:resource_properties, :numb_value, :number_value)
		rename_column(:resource_properties, :date_value, :timestamp_value)
		change_column(:resource_properties, :timestamp_value, :timestamp)
  end

  def self.down
		rename_column(:resource_properties, :string_value, :vc_value)
		rename_column(:resource_properties, :number_value, :numb_value)
		rename_column(:resource_properties, :timestamp_value, :date_value)
		change_column(:resource_properties, :date_value, :date)
  end
end
