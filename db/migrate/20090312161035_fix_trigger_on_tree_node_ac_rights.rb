class FixTriggerOnTreeNodeAcRights < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_update_group(p_group_id integer, p_tree_node_id integer)
      RETURNS integer AS
    $BODY$
            BEGIN

            delete from cms_cache_tree_node_ac_rights where user_id in (select user_id from groups_users where group_id = p_group_id) and tree_node_id = p_tree_node_id;

            INSERT INTO cms_cache_tree_node_ac_rights
              select * from cms_all_treenode_max_user_permission
              where user_id in (select user_id from groups_users where group_id = p_group_id) and tree_node_id = p_tree_node_id;

            analyze cms_cache_tree_node_ac_rights;

            RETURN 1;
            END
          $BODY$
      LANGUAGE 'plpgsql' VOLATILE;

    CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_alter()
      RETURNS trigger AS
    $BODY$
              DECLARE
            l_i  integer;
            l_tn integer;
            l_id integer;
              BEGIN

            if TG_OP = 'INSERT' then
              l_id := NEW.group_id;
              l_tn := NEW.tree_node_id;
            else
              l_id := OLD.group_id;
              l_tn := OLD.tree_node_id;
            end if;

            select cms_cache_tree_node_ac_rights_update_group(l_id, l_tn) into l_i;

            RETURN NEW;

              END;
          $BODY$
      LANGUAGE 'plpgsql' VOLATILE;
      my_code
      execute sql

  end

  def self.down
  end
end
