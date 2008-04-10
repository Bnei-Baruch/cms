class CreateFuncGetSubtree < ActiveRecord::Migration
  def self.up
    execute "
    CREATE TRUSTED PROCEDURAL LANGUAGE 'plpgsql'
    HANDLER plpgsql_call_handler
    LANCOMPILER 'PL/pgSQL';
    "
    execute "
    -- lets maintain CMS subset of database level functions. We will call 'em cms_*

    -- cms_resource_subtree function returns the complete subtree (tree_nodes) of the select
    -- resource_id (i.e. by website resource_id)
    -- i.e. select * from cms_website_subtree(68)

    CREATE OR REPLACE FUNCTION cms_resource_subtree(p_res_id integer) RETURNS SETOF tree_nodes AS $BODY$
    DECLARE
      tn  text;
      rw  tree_nodes%rowtype;
    BEGIN
        select id into tn from tree_nodes where resource_id = p_res_id and is_main = TRUE;
        FOR rw IN SELECT a.*
          FROM
            connectby('tree_nodes', 'id', 'parent_id', 'position',  tn, 0) 
              AS t(id int, parent_id int, level integer, position int) 
            join tree_nodes a on (a.id = t.id)
          ORDER BY
            t.position
        LOOP
            RETURN NEXT rw;
        END LOOP;
        RETURN;
    END
    $BODY$
    LANGUAGE 'plpgsql' ;
    
    "
  end

  def self.down
    execute "DROP FUNCTION cms_resource_subtree(p_res_id integer)"
  end
end
