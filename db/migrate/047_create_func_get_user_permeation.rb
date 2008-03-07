class CreateFuncGetUserPermeation < ActiveRecord::Migration
  def self.up
    execute "CREATE OR REPLACE FUNCTION get_user_permeation(
       integer/*user*/, integer/*tree_node_id*/
    ) RETURNS integer AS $$
	select max(ac_type) as max_ac_type from tree_node_ac_rights
	where tree_node_id=$2 and group_id in 
		(select g.id from groups g inner join groups_users gu ON g.id=gu.group_id
		where gu.user_id=$1 and (LENGTH(RTRIM(g.reason_of_ban))=0 OR g.reason_of_ban is NULL))
      $$ LANGUAGE SQL;"
  end

  def self.down
    execute "DROP FUNCTION get_user_permeation(integer, integer)"
  end
end
