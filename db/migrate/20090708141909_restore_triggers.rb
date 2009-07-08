class RestoreTriggers < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    DROP TRIGGER cms_cache_groups_trigger ON groups;

CREATE TRIGGER cms_cache_groups_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON groups
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_groups_alter();

DROP TRIGGER cms_groups_banned_trigger ON groups;

CREATE TRIGGER cms_groups_banned_trigger
  BEFORE INSERT OR UPDATE
  ON groups
  FOR EACH ROW
  EXECUTE PROCEDURE cms_banned_update();

DROP TRIGGER cms_cache_groups_users_trigger ON groups_users;

CREATE TRIGGER cms_cache_groups_users_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON groups_users
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_groups_users_alter();

DROP TRIGGER cms_cache_properties_trigger ON properties;

CREATE TRIGGER cms_cache_properties_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON properties
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_properties_alter();

DROP TRIGGER cms_cache_resource_properties_trigger ON resource_properties;

CREATE TRIGGER cms_cache_resource_properties_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON resource_properties
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_resource_properties_alter();

DROP TRIGGER cms_cache_resources_trigger ON resources;

CREATE TRIGGER cms_cache_resources_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON resources
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_resources_alter();

DROP TRIGGER cms_cache_tree_node_ac_rights_trigger ON tree_node_ac_rights;

CREATE TRIGGER cms_cache_tree_node_ac_rights_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON tree_node_ac_rights
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_tree_node_ac_rights_alter();

DROP TRIGGER cms_cache_tree_nodes_trigger ON tree_nodes;

CREATE TRIGGER cms_cache_tree_nodes_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON tree_nodes
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_tree_nodes_alter();

DROP TRIGGER cms_cache_users_trigger ON users;

CREATE TRIGGER cms_cache_users_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON users
  FOR EACH ROW
  EXECUTE PROCEDURE cms_cache_users_alter();

DROP TRIGGER cms_users_banned_trigger ON users;

CREATE TRIGGER cms_users_banned_trigger
  BEFORE INSERT OR UPDATE
  ON users
  FOR EACH ROW
  EXECUTE PROCEDURE cms_banned_update();

    
my_code
 execute sql
  end

  def self.down
  end
end
