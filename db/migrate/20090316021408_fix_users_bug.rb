class FixUsersBug < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
      CREATE OR REPLACE FUNCTION cms_cache_users_alter() RETURNS "trigger" AS
      $BODY$
      DECLARE
        l_i  integer := 0;
        l_id integer := 0;
      BEGIN

        if TG_OP = 'DELETE' then	
          l_id := OLD.id;
        elsif TG_OP = 'UPDATE' then
          if OLD.banned <> NEW.banned then
            l_id := OLD.id;
          end if;
        end if;

        if l_id > 0 then
          select cms_cache_tree_node_ac_rights_update_user(l_id) into l_i;
        end if;

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
