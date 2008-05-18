class AddUseHomepageWithoutPrefixToWebsite < ActiveRecord::Migration
  def self.up
    add_column :websites, :use_homepage_without_prefix, :boolean, :default => false
  end

  def self.down
    remove_column :websites, :use_homepage_without_prefix
  end
end
