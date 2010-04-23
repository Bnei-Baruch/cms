require 'benchmark'

class RemoveFileFromAttachments < ActiveRecord::Migration

  def self.up
    execute 'alter table attachments drop column file;'
  end

  def self.down
    add_column :attachments, :file, :binary
  end
end
