-- lets maintain CMS subset of database level functions. We will call 'em cms_*

-- Adds stress test data to the database tables

CREATE OR REPLACE FUNCTION cms_add_stress_data(p_rate integer) RETURNS boolean AS $BODY$
DECLARE
  rest_num integer;
  res_num  integer;
  i        integer;
  j        integer;
  r        integer;
  p        integer;
BEGIN

  -- Lets remove all possibly existing stress data first
  PERFORM cms_rem_stress_data();

  -- Set the number of resource types
  rest_num := p_rate / 10;
  if rest_num > 100 then
    rest_num := 100;
  end if;
  res_num := p_rate / rest_num;

  -- Adding resource types  
  FOR i IN 1..rest_num LOOP
  
    select nextval('resource_types_id_seq') into r;
    INSERT INTO resource_types
      (id, "name", created_at, updated_at, hrid)
    VALUES 
      (r, 'STRESSD_' || i, now(), now(), 'STRESSD_' || i);
    
    -- Adding resources  
    FOR j IN 1..res_num LOOP
      select nextval('resources_id_seq') into p;
      INSERT INTO resources
        (id, resource_type_id)
      VALUES 
        (p, r);
    END LOOP;
    
  END LOOP;

  return true;

END
$BODY$
LANGUAGE 'plpgsql' ;

-- Removes stress test data to the database tables

CREATE OR REPLACE FUNCTION cms_rem_stress_data() RETURNS boolean AS $BODY$
BEGIN

  DELETE FROM resources WHERE id IN (SELECT id FROM resource_types WHERE "name" like 'STRESSD_%' and hrid like 'STRESSD_%');
  DELETE FROM resource_types WHERE "name" like 'STRESSD_%' and hrid like 'STRESSD_%';

  return true;

END
$BODY$
LANGUAGE 'plpgsql' ;

-- cms_resource_subtree function returns the complete subtree (tree_nodes) of the select
-- resource_id (i.e. by website resource_id) i.e. select * from cms_resource_subtree(68)

CREATE OR REPLACE FUNCTION cms_resource_subtree(p_res_id integer) RETURNS SETOF tree_nodes AS $BODY$
DECLARE
  tn  integer;
  rw  tree_nodes%rowtype;
BEGIN
    select id into tn from tree_nodes where resource_id = p_res_id and is_main = TRUE;
    FOR rw IN SELECT * FROM cms_treenode_subtree(tn)
    LOOP
        RETURN NEXT rw;
    END LOOP;
    RETURN;
END
$BODY$
LANGUAGE 'plpgsql' ;

-- cms_resource_subtree function returns the complete subtree (tree_nodes) of the select
-- tree_node.id i.e. select * from cms_treenode_subtree(17)

CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id integer) RETURNS SETOF tree_nodes AS $BODY$
DECLARE
  rw  tree_nodes%rowtype;
BEGIN
    FOR rw IN SELECT a.*
      FROM
        connectby('tree_nodes', 'id', 'parent_id', 'position',  cast(p_tn_id AS text), 0) 
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