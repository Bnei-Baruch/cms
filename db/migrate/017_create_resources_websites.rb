class CreateResourcesWebsites < ActiveRecord::Migration
	def self.up
		create_table :resources_websites, :id => false do |t|
			t.column :resource_id, :integer
			t.column :website_id, :integer
		end
		
		add_index :resources_websites, :resource_id
		add_index :resources_websites, :website_id
	
	end
	
	def self.down
		drop_table :resources_websites
	end
end
