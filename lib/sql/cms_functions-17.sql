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

CREATE OR REPLACE VIEW cms_resource_properties_linear AS 
 SELECT rp.resource_id, p.hrid, 
        CASE p.field_type
            WHEN 'String'::text THEN rp.string_value::text
            WHEN 'Text'::text THEN rp.text_value
            WHEN 'Plaintext'::text THEN rp.text_value
            WHEN 'Boolean'::text THEN rp.boolean_value::text
            WHEN 'Number'::text THEN rp.number_value::text
            WHEN 'Date'::text THEN rp.timestamp_value::date::text
            WHEN 'Timestamp'::text THEN rp.timestamp_value::text
            WHEN 'File'::text THEN a.filename::text
            ELSE NULL::text
        END AS "value"
   FROM resource_properties rp
   JOIN properties p ON rp.property_id = p.id
   LEFT JOIN attachments a ON a.resource_property_id = rp.id
  ORDER BY rp.resource_id, p.hrid;

CREATE OR REPLACE VIEW cms_properties_fields AS 
 SELECT DISTINCT a.hrid, (lower("substring"(a.field_type::text, '^.'::text)) || '_'::text) || a.hrid::text AS field_name, lower(a.field_type::text) AS field_type
   FROM ( SELECT DISTINCT p.hrid, 
                CASE p.field_type
                    WHEN 'String'::text THEN 'text'::character varying
                    WHEN 'Number'::text THEN 'numeric'::character varying
                    WHEN 'Plaintext'::text THEN 'text'::character varying
                    WHEN 'File'::text THEN 'text'::character varying
                    ELSE p.field_type
                END AS field_type
           FROM properties p
          ORDER BY p.hrid, 
                CASE p.field_type
                    WHEN 'String'::text THEN 'text'::character varying
                    WHEN 'Number'::text THEN 'numeric'::character varying
                    WHEN 'Plaintext'::text THEN 'text'::character varying
                    WHEN 'File'::text THEN 'text'::character varying
                    ELSE p.field_type
                END) a
  ORDER BY a.hrid, (lower("substring"(a.field_type::text, '^.'::text)) || '_'::text) || a.hrid::text, lower(a.field_type::text);

-- ################################################################################
-- CMS support functions
-- ################################################################################

CREATE OR REPLACE FUNCTION cms_property_fields()
  RETURNS varchar AS
$BODY$
DECLARE
  l_ret   varchar := 'resource_id integer';
  l_f     varchar;
  l_h     varchar;
BEGIN
  for l_h, l_f in select hrid, ',"' || field_name || '" ' || field_type from cms_properties_fields order by hrid loop
    l_ret := l_ret || l_f;
  end loop;
  RETURN l_ret;
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

CREATE OR REPLACE FUNCTION cms_res_properties_where_pipe(
	p_where character varying)
	RETURNS SETOF integer AS $BODY$
DECLARE
  c refcursor;
  i integer;
  q varchar;
BEGIN

  -- if no where - give up
  if p_where is null or p_where = '' then
    return;
  end if;

  -- construct cool query
  q := 'SELECT distinct r.resource_id FROM (
	SELECT * FROM crosstab(''select * from cms_resource_properties_linear order by 1, 2'', ''select distinct p.hrid from properties p order by 1'')
	AS ct(' || cms_property_fields()	 || ')) r where ' || p_where;

  -- iterate through results
  open c for EXECUTE q;
  loop
    fetch c into i;
    exit when NOT FOUND;
    return next i;
  end loop;
  close c;
  return;
END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

-- ################################################################################
-- Main stuff (was requested by Rami)
-- ################################################################################

/**
 cms_treenode_subtree function returns the complete subtree (tree_nodes) of the select
 tree_node.id and other optional argument combinations. Parameters:

 - p_tn_id       	integer		: top tree node id (required)
 - p_user_id            integer         : user_id who access data (required)
 - p_res_hrids   	varchar[]	: array of resource type hrids to return (optional, default = ANY)
 - p_is_main     	boolean		: return object value of tree_nodes.is_main (optional, default = ANY)
 - p_has_url     	boolean		: return object value of tree_nodes.has_url (optional, default = ANY)
 - p_depth       	integer		: subtree depth level (optional, default = 0)
 - p_where  		varchar 	: where clause for properties on hrids:
					  hrid = value [and or] hrid ~ value, i.e. '(t_name ~ ''arvut'' or b_in_group) and (date > now() or date < now() + 15)'
					  NOTE: keep in mind that you are writing a normal query according field type and all other rules!
						the difference is that fieldnames are properties.hrids and values are resource_properties.
					  NOTE: all fields are prefixed by type first letter
 - p_page_num    	integer		: page number, i.e. 0,1,2,3, etc (optional, default = ALL)
 - p_page_size   	integer		: page size (optional, default = 25)
 - p_return_parent	boolean		: return parent (p_tn_id) or not (optional, default = false)
 - p_placeholders       varchar[]       : array of tree node placeholders to return to (optional, default = ANY)
 - p_statuses    	varchar[]	: array of p_tn_id children resource statuses to return to (optional, default = 'PUBLISHED')

 Valid examples:
 
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], true, true, 2, null, 0, 0, true, null, null)
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], true, null, 1, null, null, null, null, null, null)
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], null, null, 1, null, null, null, false, null, null)
   select * from cms_treenode_subtree(17, 1, null, null, null, null, null, 3, 20, null, null, null)
   select * from cms_treenode_subtree(17, 1, null, false, null, 2, null, 1, null, null, null, ARRAY['ARCHIVED'])
   select * from cms_treenode_subtree(17, 1, null, true, null, 1, null, null, null, null, null, null)
   select * from cms_treenode_subtree(17, 1, ARRAY['content_page','website'], null, false, null, 'title = ''sdasf'' and sub_title is null', 0, 10, null, null, null)
   select * from cms_treenode_subtree(17,1,ARRAY['content_page'],null,null,null,'not hide_on_navigation',null,null,null,null,ARRAY['PUBLISHED','DRAFT','ARCHIVED'])
   select * from cms_treenode_subtree(17,1,ARRAY['content_page'],null,null,null,null,null,null,null,null,ARRAY['PUBLISHED','DRAFT','ARCHIVED'])
   select * from cms_treenode_subtree(17,1,ARRAY['content_page'],null,null,null,'hide_on_navigation',null,null,null,null,ARRAY['PUBLISHED','DRAFT','ARCHIVED']) 

*/

CREATE OR REPLACE FUNCTION cms_treenode_subtree(
	p_tn_id 	integer, 			-- required
        p_user_id       integer, 			-- required
	p_res_hrids	varchar[],  			-- optional
	p_is_main 	boolean,  			-- optional
	p_has_url 	boolean,  			-- optional
	p_depth 	integer,  			-- optional
	p_where 	character varying,  		-- optional
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
      (p_res_hrids is null    or b.resource_type_id IN (select id from resource_types where hrid = ANY (p_res_hrids))) and
      (p_placeholders is null or a.placeholder = ANY (p_placeholders)) and
      (p_where is null        or a.resource_id IN (select * from cms_res_properties_where_pipe(p_where)))
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
 cms_treenode_ancestors function returns the set oof parents based on supplied
tree_nodes.id and user_id permissions. Parameters:

 - p_tn_id       	integer		: top tree node id (required)
 - p_user_id            integer         : user_id who access data (required)

 Valid examples:
 
   select * from cms_treenode_ancestors(84, 1)
 
*/

CREATE OR REPLACE FUNCTION cms_treenode_ancestors(
	p_tn_id 	integer, 			-- required
        p_user_id       integer) 			-- required
	RETURNS SETOF tree_nodes AS $BODY$
DECLARE
  tn_rec       	tree_nodes%rowtype;
  rec		record;
  l_tn_id	integer := p_tn_id;
BEGIN

  -- Main loop
  LOOP

    SELECT
      a.id, a.parent_id, b.status, COALESCE(c.max_ac_type, 0) as max_ac_type
    INTO
      rec
    FROM
      tree_nodes					a
      join resources                                 	b on (a.resource_id = b.id)
      left join cms_all_treenode_max_user_permission 	c on (c.tree_node_id = a.id and p_user_id = c.user_id)
    WHERE
      l_tn_id = a.id;

    -- User does not have permission on this node? return
    -- if the resource of that node is PUBLISHED or ARCHIVED and the group has ac_type >= 1 it is returned
    -- if the resource of that node is DRAFT and the group has ac_type >= 2 it is returned
    -- if the resource of that node is DELETED and the group has ac_type >= 3 it is returned
    EXIT when rec.max_ac_type <= 0 or (rec.status = 'DRAFT' and rec.max_ac_type < 2) or (rec.status = 'DELETED' and rec.max_ac_type < 3);

    -- Do not return myself!
    if rec.id <> p_tn_id then
      -- At last! Return next record!
      select * into tn_rec from tree_nodes where id = rec.id;
      tn_rec.max_user_permission := rec.max_ac_type;
      RETURN NEXT tn_rec;
    end if;

    -- If we are on top; exit
    EXIT WHEN COALESCE(rec.parent_id, 0) = 0;

    -- Move up and loop again
    l_tn_id := rec.parent_id;

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

	