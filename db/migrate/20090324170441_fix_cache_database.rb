class FixCacheDatabase < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    ALTER TABLE cms_cache_outdated_pages
       ALTER COLUMN date SET DEFAULT 'UNDEF';

    CREATE OR REPLACE FUNCTION cms_cache_outdated_pages_refresh(f_table boolean)
      RETURNS integer AS
    $BODY$begin

            if f_table then

            DROP TABLE IF EXISTS cms_cache_outdated_pages;

            CREATE TABLE cms_cache_outdated_pages
            (
              page_id integer NOT NULL,
              date varchar(100) NOT NULL DEFAULT 'UNDEF',
              CONSTRAINT cms_cache_outdated_pages_pk PRIMARY KEY (page_id)
            )
              WITH (OIDS=FALSE);
            else
              delete from cms_cache_outdated_pages;
            end if;


            return 1;

          end;
          $BODY$
      LANGUAGE 'plpgsql' VOLATILE;

    CREATE OR REPLACE FUNCTION cms_cache_outdate_page(p_resource_id integer, p_tree_node_id integer)
      RETURNS integer AS
    $BODY$
          begin

    	if p_resource_id is not null then

    	  UPDATE
    	    cms_cache_outdated_pages 
    	  SET
    	    date = 'UNDEF'
    	  WHERE
    	    page_id IN ( 
    	    SELECT distinct
    	      parent_id
    	    FROM			
    	      page_maps
    	    WHERE
    	      (child_id  in (select id from tree_nodes where resource_id = p_resource_id)  or
    	       parent_id in (select id from tree_nodes where resource_id = p_resource_id)  or
    	       child_id  in (select COALESCE(parent_id, -1) from tree_nodes where resource_id = p_resource_id) or
    	       parent_id in (select COALESCE(parent_id, -1) from tree_nodes where resource_id = p_resource_id)));

    	  INSERT INTO
    	    cms_cache_outdated_pages 
    	    (page_id) 
    	    SELECT distinct
    	      parent_id
    	    FROM			
    	      page_maps
    	    WHERE
    	      (child_id  in (select id from tree_nodes where resource_id = p_resource_id)  or
    	       parent_id in (select id from tree_nodes where resource_id = p_resource_id)  or
    	       child_id  in (select COALESCE(parent_id, -1) from tree_nodes where resource_id = p_resource_id) or
    	       parent_id in (select COALESCE(parent_id, -1) from tree_nodes where resource_id = p_resource_id)) and
    	      parent_id not in (select page_id from cms_cache_outdated_pages);

    	end if;

    	if p_tree_node_id is not null then

    	  UPDATE
    	    cms_cache_outdated_pages 
    	  SET
    	    date = 'UNDEF'
    	  WHERE
    	    page_id IN ( 
    	    SELECT distinct
    	      parent_id
    	    FROM
    	      page_maps
    	    WHERE
    	      (child_id = p_tree_node_id or
    	       parent_id = p_tree_node_id or
    	       child_id  in (select COALESCE(parent_id, -1) from tree_nodes where id = p_tree_node_id) or
    	       parent_id in (select COALESCE(parent_id, -1) from tree_nodes where id = p_tree_node_id)));

    	  INSERT INTO 
    	    cms_cache_outdated_pages 
    	    (page_id) 
    	    SELECT distinct
    	      parent_id
    	    FROM
    	      page_maps
    	    WHERE
    	      (child_id = p_tree_node_id or
    	       parent_id = p_tree_node_id or
    	       child_id  in (select COALESCE(parent_id, -1) from tree_nodes where id = p_tree_node_id) or
    	       parent_id in (select COALESCE(parent_id, -1) from tree_nodes where id = p_tree_node_id)) and
    	       parent_id not in (select page_id from cms_cache_outdated_pages);

    	end if;

            -- delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);

            return 1;
          end
          $BODY$
      LANGUAGE 'plpgsql' VOLATILE;

    CREATE OR REPLACE FUNCTION cms_cache_resource_properties_alter()
      RETURNS trigger AS
    $BODY$
        DECLARE
    	l_res_id integer;
    	l_rows integer;
    	l_i integer;
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

    	select cms_cache_outdate_page(l_res_id, null) into l_i;

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

    	select cms_cache_outdate_page(l_i, null) into l_i;

            RETURN NEW;

        END;
    $BODY$
      LANGUAGE 'plpgsql' VOLATILE;

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

    	select cms_cache_outdate_page(null, l_i) into l_i;

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
