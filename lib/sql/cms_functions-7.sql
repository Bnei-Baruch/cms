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
						p_res_types    integer, 
						p_is_main      boolean, 
						p_has_url      boolean,
						p_depth        integer,
						p_properties   varchar[]);
DROP FUNCTION IF EXISTS cms_treenode_subtree(p_tn_id           integer, 
						p_res_types    integer[], 
						p_is_main      boolean, 
						p_has_url      boolean,
						p_depth        integer,
						p_properties   varchar[],
						p_page_num     integer,
						p_page_size    integer);
DROP FUNCTION IF EXISTS cms_pair_pipe(p_pairs varchar[]);
DROP FUNCTION IF EXISTS cms_properties_pipe(p_properties varchar[]);
DROP TYPE IF EXISTS cms_pair;


-- ################################################################################
-- CMS support functions
-- ################################################################################

CREATE TYPE cms_pair    AS (key character varying(255), value text);

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

CREATE OR REPLACE FUNCTION cms_integer_pipe(p_ints integer[]) RETURNS SETOF integer AS $BODY$
DECLARE
  r integer;
BEGIN
  if p_ints is not null then
    for r in array_lower(p_ints, 1)..array_upper(p_ints, 1) loop
      RETURN NEXT p_ints[r];
    end loop;
  end if;
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
 cms_treenode_subtree function returns the complete subtree (tree_nodes) of the select
 tree_node.id and other optional argument combinations. Parameters:

 - p_tn_id       integer   : top tree node id (required)
 - p_res_type_id integer[] : array of resource type ids to return (optional)
 - p_is_main     boolean   : return object value of tree_nodes.is_main (optional) 
 - p_has_url     boolean   : return object value of tree_nodes.has_url (optional) 
 - p_depth       integer   : subtree depth level (optional)
 - p_properties  varchar[] : array of property.hrid + resource_properties.* pair, i.e. ARRAY['title','sdasf','sub_title',''] (optional)
 - p_page_num    integer   : page number, i.e. 0,1,2,3, etc (optional)
 - p_page_size   integer   : page size (default: 25) (optional)

 Valid examples:
 
   select * from cms_treenode_subtree(17, ARRAY[35,10], true, true, 2, null, 0, 0)
   select * from cms_treenode_subtree(17, ARRAY[35], true, null, 1, null, null, null)
   select * from cms_treenode_subtree(17, ARRAY[35], null, null, 1, null, null, null)
   select * from cms_treenode_subtree(17, null, null, null, null, null, 3, 20)
   select * from cms_treenode_subtree(17, null, false, null, 2, null, 1, null)
   select * from cms_treenode_subtree(17, null, true, null, 1, null, null, null)
   select * from cms_treenode_subtree(17, ARRAY[35], null, false, null, ARRAY['title','sdasf','sub_title',''], 0, 10)
 
*/

CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id        integer, 
						p_res_types    integer[], 
						p_is_main      boolean, 
						p_has_url      boolean,
						p_depth        integer,
						p_properties   varchar[],
						p_page_num     integer,
						p_page_size    integer) RETURNS SETOF tree_nodes AS $BODY$
DECLARE
  rw          tree_nodes%rowtype;
  l_depth     integer := p_depth;
  l_page_size integer := p_page_size;
  l_item      integer := 0;
  l_item_f    integer := 0;
  l_item_l    integer := 2147483647;
BEGIN

  if l_page_size is null or l_page_size <= 0 then
    l_page_size := 25;
  end if;

  if p_page_num is not null then
    if p_page_num >= 0 then
      l_item_f := p_page_num * l_page_size;
      l_item_l := l_item_f + l_page_size;
    end if;
  end if;

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
      (p_res_types is null   or b.resource_type_id IN (select * from cms_integer_pipe(p_res_types))) and
      (p_has_url is null     or has_url = p_has_url) and
      (p_is_main is null     or is_main = p_is_main) and
      (p_properties is null  or a.resource_id IN (select resource_id from cms_properties_pipe(p_properties)))
    ORDER BY
      t.position
  LOOP
    if l_item >= l_item_l then
      exit;
    end if;
    if l_item >= l_item_f and l_item < l_item_l then
      RETURN NEXT rw;
    end if;
    l_item := l_item + 1;
  END LOOP;
  
  RETURN;
  
END
$BODY$
LANGUAGE 'plpgsql' ;

/*
 cms_treenode_ancestor_on_permssions function returns treenode.id (tree_nodes) value of the first provided 
 ancestor treenode anchestor that satisfies the given optional argument combination. Parameters:

 - p_tn_id       integer   : tree node id to start searching anchestor from (required)
 - p_group_id    integer   : group id of the ancestor (optional)
 - p_is_auto     boolean   : is_Automatic value of the ancestor (optional) 

 Note: if conditions satisfy this function returns itself first!!!!
 
 Valid examples:
 
   select * from tree_nodes where id = cms_treenode_ancestor_on_permssions(31, null, true)
 
*/

CREATE OR REPLACE FUNCTION cms_treenode_ancestor_on_permssions(p_tn_id      integer, 
						               p_group_id   integer,
						               p_is_auto    boolean) RETURNS SETOF tree_nodes AS $BODY$
DECLARE
  l_id      integer := p_tn_id;
  l_parent  integer;
  l_ok      boolean;
  rw        tree_nodes%rowtype;
BEGIN
  LOOP
  
    begin
    
      select 
        a.parent_id, 
        ((COALESCE(p_group_id, b.group_id) = b.group_id) and (COALESCE(p_is_auto, b.is_automatic) = b.is_automatic))
      into
        l_parent,
        l_ok
      from 
        tree_nodes a 
          left join 
        tree_node_ac_rights b 
          on (b.tree_node_id = a.id) 
      where 
        a.id = l_id;
        
    exception when others then
      return;
    end;

    if l_ok is null then
      return;
    end if;

    if l_ok then
      select * into rw from tree_nodes where id = l_id;
      return next rw;
      return;
    end if;

    l_id := l_parent;
    
  END LOOP;
  return;
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

