class AddStatusToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :status, :string, :default => 'DRAFT'
    execute "update resources set status = 'PUBLISHED';"
    execute "ALTER TABLE resources ADD CONSTRAINT resrource_status_ck CHECK (status in ('DRAFT', 'PUBLISHED','ARCHIVED','DELETED'));"
  end

  def self.down
    execute "ALTER TABLE resources DROP CONSTRAINT resrource_status_ck;"
    remove_column :resources, :status
  end
end
