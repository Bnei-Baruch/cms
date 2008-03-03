class ChangeAutColumnNames < ActiveRecord::Migration
  def self.up
    rename_column(:users, :banned_reson, :reason_of_ban)
    rename_column(:groups, :banned_reason, :reason_of_ban)
  end

  def self.down
    rename_column(:groups, :reason_of_ban, :banned_reason)
    rename_column(:users, :reason_of_ban, :banned_reson)
  end
end
