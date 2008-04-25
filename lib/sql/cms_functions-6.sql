-- ################################################################################
-- ################################################################################
--
-- lets maintain CMS subset of database level functions. We will call 'em cms_*
--
-- ################################################################################
-- ################################################################################



-- ################################################################################
-- Drop something to be able to drop others ;)
-- ################################################################################

DROP FUNCTION IF EXISTS cms_treenode_subtree(p_tn_id           integer, 
						p_res_type_id  integer, 
						p_is_main      boolean, 
						p_has_url      boolean,
						p_depth        integer,
						p_properties   varchar[] );
DROP FUNCTION IF EXISTS cms_pair_pipe(p_pairs varchar[]);
DROP FUNCTION IF EXISTS cms_properties_pipe(p_properties varchar[]);
DROP TYPE IF EXISTS cms_pair;



-- ################################################################################
-- CMS support functions
-- ################################################################################

CREATE TYPE cms_pair AS (key character varying(255), value text);

CREATE OR REPLACE FUNCTION cms_pair_pipe(p_pairs varchar[]) RETURNS SETOF cms_pair AS $BODY$
DECLARE
  r integer;
  p cms_pair;
BEGIN
  for r in array_lower(p_pairs, 1)..array_upper(p_pairs, 1) loop
    p.key := p_pairs[r];
    r := r + 1;
    if array_upper(p_pairs, 1) < r then
      p.value := NULL;
    else
      p.value := p_pairs[r];
    end if;
    RETURN NEXT p;
  end loop;
  RETURN;
END
$BODY$
LANGUAGE 'plpgsql' ;

CREATE OR REPLACE FUNCTION cms_safe_cast(p_str anyelement, p_type anyelement) RETURNS anyelement AS $BODY$
BEGIN
  if p_type = 'varchar' then
    return CAST(p_str AS varchar);
  elsif p_type = 'text' then
    return CAST(p_str AS text);
  elsif p_type = 'numeric' then
    return CAST(p_str AS numeric);
  elsif p_type = 'boolean' then
    return CAST(p_str AS boolean);
  else
    return NULL;
  end if;
EXCEPTION WHEN OTHERS THEN
  return NULL;
END
$BODY$
LANGUAGE 'plpgsql' ;

CREATE OR REPLACE FUNCTION cms_properties_pipe(p_properties varchar[]) RETURNS SETOF resource_properties AS $BODY$
DECLARE
  rw      resource_properties%rowtype;
BEGIN
  FOR rw IN select 
      rp.* 
    from
      resource_properties rp,
      properties p,
      cms_pair_pipe(p_properties) pa
    where
      p.hrid = pa.key and (
        (rp.string_value    like cms_safe_cast(pa.value, 'varchar') and rp.property_type = 'RpString') or
        (rp.text_value      like cms_safe_cast(pa.value, 'varchar') and rp.property_type = 'RpPlaintext') or
        (rp.number_value    =    CAST(cms_safe_cast(pa.value, 'numeric') AS NUMERIC) and rp.property_type = 'RpNumber') or
        (rp.boolean_value   =    CAST(cms_safe_cast(pa.value, 'boolean') AS BOOLEAN) and rp.property_type = 'RpBoolean') or
        (rp.timestamp_value =    CAST(cms_safe_cast(pa.value, 'timestamp') AS TIMESTAMP) and rp.property_type = 'RpTimestamp')
      ) 
  LOOP
    RETURN NEXT rw;
  END LOOP;
  RETURN;
END
$BODY$
LANGUAGE 'plpgsql' ;

-- ################################################################################
-- Main stuff (was requested by Rami)
-- ################################################################################

/*
 cms_resource_subtree function returns the complete subtree (tree_nodes) of the select
 tree_node.id and other optional argument combinations. Parameters:

 - p_tn_id       integer   : top tree node id (required)
 - p_res_type_id integer   : resource type id to return (optional)
 - p_is_main     boolean   : return object value of tree_nodes.is_main (optional) 
 - p_has_url     boolean   : return object value of tree_nodes.has_url (optional) 
 - p_depth       integer   : subtree depth level (optional)
 - p_properties  varchar[]: array of property.hrid + resource_properties.* pair, i.e. ARRAY['title','sdasf','sub_title','']

 Valid examples:
 
   select * from cms_treenode_subtree(17, cast(35 as integer), true, true, 2, null)
   select * from cms_treenode_subtree(17, cast(35 as integer), true, null, 1, null)
   select * from cms_treenode_subtree(17, cast(35 as integer), null, null, 1, null)
   select * from cms_treenode_subtree(17, null, null, null, null, null)
   select * from cms_treenode_subtree(17, null, false, null, 2, null)
   select * from cms_treenode_subtree(17, null, true, null, 1, null)
   select * from cms_treenode_subtree(17, cast(35 as integer), null, false, null, ARRAY['title','sdasf','sub_title',''])
 
*/

CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id        integer, 
						p_res_type_id  integer, 
						p_is_main      boolean, 
						p_has_url      boolean,
						p_depth        integer,
						p_properties   varchar[] ) RETURNS SETOF tree_nodes AS $BODY$
DECLARE
  rw      tree_nodes%rowtype;
  l_depth integer := p_depth;
BEGIN

  if l_depth is null then
    l_depth := 0;
  end if;
  
  FOR rw IN SELECT a.*
    FROM
      connectby('tree_nodes', 'id', 'parent_id', 'position',  cast(p_tn_id AS text), l_depth) 
      AS t(id int, parent_id int, level integer, position int) 
      join tree_nodes a on (a.id = t.id)
      join resources  b on (a.resource_id = b.id)
    WHERE
      (b.resource_type_id = p_res_type_id or p_res_type_id is null) and
      (p_has_url is null    or has_url = p_has_url) and
      (p_is_main is null    or is_main = p_is_main) and
      (p_properties is null or a.resource_id IN (select resource_id from cms_properties_pipe(p_properties)))
    ORDER BY
      t.position
  LOOP
    RETURN NEXT rw;
  END LOOP;
  
  RETURN;
  
END
$BODY$
LANGUAGE 'plpgsql' ;



-- ################################################################################
-- Stress test functions
-- ################################################################################

CREATE OR REPLACE FUNCTION cms_add_stress_data(p_rate integer) RETURNS boolean AS $BODY$
DECLARE
  rest_num integer;
  res_num  integer;
  i        integer;
  j        integer;
  r        integer;
  p        integer;

  -- Levels of ranges
  ranges   integer[][];

BEGIN

  -- Lets remove all possibly existing stress data first
  PERFORM cms_rem_stress_data();

  -- Set the number of resource types
  rest_num := p_rate / 10;
  if rest_num > 100 then
    rest_num := 100;
  end if;
  res_num := 2;
  j := 1;
  p := 1;

  -- Looping through resource types  
  FOR i IN 1..rest_num LOOP

    select nextval('resource_types_id_seq') into r;
	
    if i > res_num then
      res_num := res_num + res_num * 2;
      j := j + 1;
      p := 1;
    end if;
    ranges[j][p] := r;
    p := p + 1;

    -- Adding resource type
    INSERT INTO resource_types
      (id, "name", created_at, updated_at, hrid)
    VALUES 
      (r, 'STRESSD_' || i, now(), now(), 'STRESSD_' || i);

  END LOOP;

  j := 1;
  
  -- Adding resources
  FOR i IN 1..res_num LOOP

    select nextval('resources_id_seq') into p;

    

    INSERT INTO resources
      (id, resource_type_id)
    VALUES 
      (p, r);

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

