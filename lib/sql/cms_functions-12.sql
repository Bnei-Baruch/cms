-- ################################################################################
-- ################################################################################
--
-- lets maintain CMS subset of database level functions. We will call 'em cms_*
--
-- ################################################################################
-- First of all - lets remove old stuff
-- ################################################################################
/*
CREATE OR REPLACE FUNCTION cms_remove_me() returns integer AS $BODY$
DECLARE
  l_name varchar;
  l_type varchar;
BEGIN

  FOR l_name, l_type IN 
    SELECT
      routine_name, routine_type
    FROM 
      information_schema.routines
    WHERE
      specific_schema NOT IN ('pg_catalog', 'information_schema') AND
      type_udt_name != 'trigger' and
      routine_name ~ '^cms_' and
      routine_name !~ 'cms_remove_me' LOOP
    
    execute 'DROP ' || l_type || ' ' || l_name || '()';

  END LOOP;
  return 1;
END
$BODY$
LANGUAGE 'plpgsql' VOLATILE;
*/
-- ################################################################################
-- Views
-- ################################################################################

CREATE OR REPLACE VIEW cms_all_treenode_max_user_permission AS 
  SELECT 
    r.tree_node_id,
    gu.user_id,
    max(r.ac_type) AS max_ac_type
  FROM 
    tree_node_ac_rights r
    JOIN groups g ON r.group_id = g.id AND length(rtrim(COALESCE(g.reason_of_ban, ''::character varying)::text)) = 0
    JOIN groups_users gu ON g.id = gu.group_id
    JOIN users u ON gu.user_id = u.id AND length(rtrim(COALESCE(u.reason_of_ban, ''::character varying)::text)) = 0
  GROUP BY 
    r.tree_node_id, 
    gu.user_id;

-- ################################################################################
-- CMS support functions
-- ################################################################################

DROP TYPE cms_pair CASCADE;

CREATE TYPE cms_pair    AS (key character varying(255), value text);

CREATE OR REPLACE FUNCTION cms_pair_pipe(p_pairs character varying[])
  RETURNS SETOF cms_pair AS
$BODY$
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
  LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION cms_integer_pipe(p_ints integer[])
  RETURNS SETOF integer AS
$BODY$
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
  LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION cms_varchar_pipe(p_vcs varchar[])
  RETURNS SETOF varchar AS
$BODY$
DECLARE
  r integer;
BEGIN
  if p_vcs is not null then
    for r in array_lower(p_vcs, 1)..array_upper(p_vcs, 1) loop
      RETURN NEXT p_vcs[r];
    end loop;
  end if;
  RETURN;
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION cms_bool_to_varchar(p_b boolean) RETURNS varchar AS $BODY$
BEGIN
  if p_b is null then
    return null;
  end if;
  if p_b then
    return 't';
  end if;
  return 'f';
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION cms_properties_pipe(
	p_properties character varying[])
	RETURNS SETOF resource_properties AS $BODY$
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
      rp.property_id = p.id and
      p.hrid = pa.key and (
        (rp.string_value    		     			like pa.value and p.field_type = 'String')    or
        (rp.text_value      		     			like pa.value and p.field_type = 'Text')      or
        (CAST(rp.number_value AS varchar)    			=    pa.value and p.field_type = 'Number')    or
        (cms_bool_to_varchar(rp.boolean_value)			=    pa.value and p.field_type = 'Boolean')   or
        (CAST(CAST(rp.timestamp_value AS DATE) AS varchar) 	=    pa.value and p.field_type = 'Date')      or
        (CAST(rp.timestamp_value AS varchar) 			=    pa.value and p.field_type = 'Timestamp')
      ) 
  LOOP
    RETURN NEXT rw;
  END LOOP;
  RETURN;
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

-- ################################################################################
-- Main stuff (was requested by Rami)
-- ################################################################################

/*
 cms_treenode_subtree function returns the complete subtree (tree_nodes) of the select
 tree_node.id and other optional argument combinations. Parameters:

 - p_tn_id       	integer		: top tree node id (required)
 - p_user_id            integer         : user_id who access data (required)
 - p_res_hrids   	varchar[]	: array of resource type hrids to return (optional, default = ANY)
 - p_is_main     	boolean		: return object value of tree_nodes.is_main (optional, default = ANY)
 - p_has_url     	boolean		: return object value of tree_nodes.has_url (optional, default = ANY)
 - p_depth       	integer		: subtree depth level (optional, default = 0)
 - p_properties  	varchar[]	: array of property.hrid + resource_properties.* pair, i.e. ARRAY['title','sdasf','sub_title',''] (optional, default = ANY)
 -                                      examples for various data types:
 - 						'String'	: 'chaverim'
 - 						'Text'		: 'arvut'
 - 						'Number'	: '10', '12.0', '123.123', '0.12'
 - 						'Boolean'	: 'f' or 't'
 - 						'Date'         	: '2008-04-29'
 - 						'Timestamp'	: '2008-04-29 05:49:17.75'
 - p_page_num    	integer		: page number, i.e. 0,1,2,3, etc (optional, default = ALL)
 - p_page_size   	integer		: page size (optional, default = 25)
 - p_return_parx`ent	boolean		: return parent (p_tn_id) or not (optional, default = false)
 - p_placeholders       varchar[]       : array of tree node placeholders to return to (optional, default = ANY)
 - p_statuses    	varchar[]	: array of p_tn_id children resource statuses to return to (optional, default = 'PUBLISHED')

 Valid examples:
 
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], true, true, 2, null, 0, 0, true, null, null)
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], true, null, 1, null, null, null, null, null, null)
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], null, null, 1, null, null, null, false, null, null)
   select * from cms_treenode_subtree(17, 1, null, null, null, null, null, 3, 20, null, null, null)
   select * from cms_treenode_subtree(17, 1, null, false, null, 2, null, 1, null, null, null, ARRAY['ARCHIVED'])
   select * from cms_treenode_subtree(17, 1, null, true, null, 1, null, null, null, null, null, null)
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], null, false, null, ARRAY['title','sdasf','sub_title',''], 0, 10, null, null, null)
 
*/

CREATE OR REPLACE FUNCTION cms_treenode_subtree(
	p_tn_id 	integer, 			-- required
        p_user_id       integer, 			-- required
	p_res_hrids	varchar[],  			-- optional
	p_is_main 	boolean,  			-- optional
	p_has_url 	boolean,  			-- optional
	p_depth 	integer,  			-- optional
	p_properties 	character varying[],  		-- optional
	p_page_num 	integer,  			-- optional
	p_page_size 	integer,  			-- optional
	p_return_parent boolean,  			-- optional
        p_placeholders  character varying[],  		-- optional
        p_statuses      character varying[])  		-- optional 
	RETURNS SETOF tree_nodes AS $BODY$
DECLARE
  tn_rec       tree_nodes%rowtype;
  rec          record;
  l_page_size  integer   := p_page_size;
  l_item       integer   := 0;
  l_item_first integer   := 0;
  l_item_last  integer   := 2147483647;
  l_skip_level integer   := 0;
  l_statuses   varchar[] := COALESCE(p_statuses, ARRAY['PUBLISHED']);
BEGIN

  -- Determine page size
  if l_page_size is null or l_page_size <= 0 then
    l_page_size := 25;
  end if;

  -- According to page size - lets set first and last numbers of records
  if p_page_num is not null then
    if p_page_num >= 0 then
      l_item_first := p_page_num * l_page_size;
      l_item_last := l_item_first + l_page_size;
    end if;
  end if;
  
  -- Main loop
  FOR rec IN SELECT 
      t.id, t.level, b.status, COALESCE(c.max_ac_type, 0) as max_ac_type
    FROM
      connectby('tree_nodes', 'id', 'parent_id', 'position',  cast(p_tn_id AS text), COALESCE(p_depth, 0)) AS t(id int, parent_id int, level integer, position int)
      join tree_nodes                                a on (t.id = a.id)
      join resources                                 b on (a.resource_id = b.id)
      left join cms_all_treenode_max_user_permission c on (c.tree_node_id = t.id and p_user_id = c.user_id)
    WHERE
      (p_has_url is null      or a.has_url = p_has_url) and
      (p_is_main is null      or a.is_main = p_is_main) and
      (p_res_hrids is null    or b.resource_type_id IN (select a.id from resource_types a where a.hrid IN (select * from cms_varchar_pipe(p_res_hrids)))) and
      (p_placeholders is null or a.placeholder IN (select * from cms_varchar_pipe(p_placeholders))) and
      (p_properties is null   or a.resource_id IN (select resource_id from cms_properties_pipe(p_properties)))
    ORDER BY
      t.position
  LOOP

    -- Its parent and not to return it? continue
    continue when not COALESCE(p_return_parent, false) and rec.id = p_tn_id;

    -- Current node is below the skipped one? continue
    continue when l_skip_level > 0 and rec.level > l_skip_level;

    -- User does not have permission on this node? skip level & continue
    -- if the resource of that node is PUBLISHED or ARCHIVED and the group has ac_type >= 1 it is returned
    -- if the resource of that node is DRAFT and the group has ac_type >= 2 it is returned
    -- if the resource of that node is DELETED and the group has ac_type >= 3 it is returned
    if rec.max_ac_type <= 0 or (rec.status = 'DRAFT' and rec.max_ac_type < 2) or (rec.status = 'DELETED' and rec.max_ac_type < 3) then
      l_skip_level := rec.level;
      continue;
    end if;

    -- Define skip level on resource STATUS if appropriate
    if rec.level > 0 then
      if rec.status = ANY (l_statuses) then
        l_skip_level := 0;
      else
        l_skip_level := rec.level;
        continue;
      end if;
    end if;

    -- increase the actual item number
    l_item := l_item + 1;

    -- Paging stuff: Already above page? exit or Still not reached first item on page? continue looping
    exit when l_item >= l_item_last;
    continue when l_item < l_item_first;

    -- At last! Return next record!
    select * into tn_rec from tree_nodes where id = rec.id;
    tn_rec.max_user_permission := rec.max_ac_type;
    RETURN NEXT tn_rec;

  END LOOP;
  
  RETURN;
  
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
/*
 cms_treenode_ancestor_on_permssions function returns treenode.id (tree_nodes) value of the first provided 
 ancestor treenode anchestor that satisfies the given optional argument combination. Parameters:

 - p_tn_id       integer   : tree node id to start searching anchestor from (required)
 - p_group_id    integer   : group id of the ancestor (optional)
 - p_is_auto     boolean   : is_Automatic value of the ancestor (optional) 

 Note: if conditions satisfy this function returns itself first!!!!
 
 Valid examples:
 
   select * from cms_treenode_ancestor_on_permssions(31, null, true)
 
*/

CREATE OR REPLACE FUNCTION cms_treenode_ancestor_on_permssions (
	p_tn_id integer, 
	p_group_id integer, 
	p_is_auto boolean)
	RETURNS SETOF tree_nodes AS $BODY$
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
      exit;
    end;

    exit when l_ok is null;

    if l_ok then
      select * into rw from tree_nodes where id = l_id;
      return next rw;
      exit;
    end if;

    l_id := l_parent;
    
  END LOOP;
  return;
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

/*
  cms_treenode_max_user_permission - gets max user permission for particular treenode
  Parameters:
  - tree_node_id
  - user_id
  - returns max user permission for treenode, ie.
	0 => "Forbidden",
	1 => "Reading",
	2 => "Editing",
	3 => "Managing",
	4 => "Administrating"
*/
CREATE OR REPLACE FUNCTION cms_treenode_max_user_permission(integer, integer) RETURNS integer AS $BODY$
  SELECT 
    max_ac_type
  FROM 
    cms_all_treenode_max_user_permission
  WHERE
    tree_node_id = $1 and
    user_id = $2
$BODY$
LANGUAGE 'sql' VOLATILE;

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

    ranges = ranges || ARRAY[j,p,r];
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

	