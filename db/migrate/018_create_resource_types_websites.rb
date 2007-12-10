class CreateResourceTypesWebsites < ActiveRecord::Migration
	def self.up
		create_table :resource_types_websites, :id => false do |t|
			t.column :resource_type_id, :integer
			t.column :website_id, :integer
		end
		
		add_index :resource_types_websites, :resource_type_id
		add_index :resource_types_websites, :website_id
	
	end
	
	def self.down
		drop_table :resource_types_websites
	end
end
