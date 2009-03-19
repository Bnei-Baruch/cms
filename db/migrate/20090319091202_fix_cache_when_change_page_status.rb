class FixCacheWhenChangePageStatus < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    CREATE OR REPLACE FUNCTION cms_prod.cms_cache_resources_alter()
      RETURNS trigger AS
    $BODY$
        DECLARE
    	l_i integer;
    	l_rows integer;
        BEGIN

    	if TG_OP = 'INSERT' then
    		insert into cms_cache_resource_properties (resource_id) values (NEW.id);
    		l_i := NEW.id;
    	elsif TG_OP = 'DELETE' then
    		delete from cms_cache_resource_properties where resource_id = OLD.id;
    		l_i := OLD.id;
    	elseif TG_OP = 'UPDATE' then
    		l_i := NEW.id;
    	end if;

    	INSERT INTO 
    		cms_cache_outdated_pages 
    		(page_id) 
    		SELECT distinct
    			parent_id
    		FROM
    			page_maps
    		WHERE
    			(child_id in (select id from tree_nodes where resource_id = l_i)  or
    			 parent_id in (select id from tree_nodes where resource_id = l_i)  or
    			 child_id in (select COALESCE(parent_id, -1) from tree_nodes where resource_id = l_i)) and
    			parent_id not in (select page_id from cms_cache_outdated_pages);

    	delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);

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
