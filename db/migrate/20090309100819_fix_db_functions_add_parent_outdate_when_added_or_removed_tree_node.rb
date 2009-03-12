class FixDbFunctionsAddParentOutdateWhenAddedOrRemovedTreeNode < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    CREATE OR REPLACE FUNCTION cms_cache_tree_nodes_alter()
      RETURNS trigger AS
    $BODY$
        DECLARE
    	l_i integer;
    	l_rows integer;
        BEGIN

    	if TG_OP = 'DELETE' then
    		delete from cms_cache_tree_node_ac_rights where tree_node_id = OLD.id;
    		l_i := OLD.id;
    	else
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
    			(child_id = l_i or
    			 child_id = (select COALESCE(parent_id, 0) from tree_nodes where id = l_i)) and
    			parent_id not in (select page_id from cms_cache_outdated_pages);

    	delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);


            RETURN NEW;

        END;
    $BODY$
      LANGUAGE 'plpgsql' VOLATILE;

    CREATE OR REPLACE FUNCTION cms_cache_resources_alter()
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
    			 child_id = (select COALESCE(parent_id, 0) from tree_nodes where resource_id = l_i)) and
    			parent_id not in (select page_id from cms_cache_outdated_pages);

    	delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);


            RETURN NEW;

        END;
    $BODY$
      LANGUAGE 'plpgsql' VOLATILE;

     CREATE OR REPLACE FUNCTION cms_cache_resource_properties_alter()
      RETURNS trigger AS
    $BODY$
        DECLARE
    	l_res_id integer;
    	l_rows integer;
        BEGIN

    	if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
    		l_res_id := NEW.resource_id;
    	elsif TG_OP = 'DELETE' then
    		l_res_id := OLD.resource_id;
    	end if;

    	delete from cms_cache_resource_properties where resource_id = l_res_id;
    	execute 'insert into cms_cache_resource_properties (' || cms_cache_properties_field_list(false) || ')
    		SELECT * FROM crosstab(
    			''select resource_id, field_name, value from cms_cache_resource_properties_linear where resource_id = ' || cast(l_res_id as varchar) || ' order by 1, 2'', 
    			''select distinct field_name from cms_cache_properties_fields order by field_name'')
    		AS ct(' || cms_cache_properties_field_list(true) || ')';

    	INSERT INTO 
    		cms_cache_outdated_pages 
    		(page_id) 
    		SELECT distinct
    			parent_id
    		FROM
    			page_maps
    		WHERE
    			(child_id in (select id from tree_nodes where resource_id = l_res_id)  or
    			 child_id = (select COALESCE(parent_id, 0) from tree_nodes where resource_id = l_res_id)) and
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
