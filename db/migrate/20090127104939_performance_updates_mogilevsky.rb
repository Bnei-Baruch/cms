class PerformanceUpdatesMogilevsky < ActiveRecord::Migration
  def self.up
		add_column :tree_nodes, :resource_status, :string
		execute "ALTER TABLE tree_nodes ADD CONSTRAINT resource_status_ck CHECK (resource_status IS NULL)"
 
sql = <<-my_code
-- Function: cms_treenode_subtree(integer, integer, character varying[], boolean, boolean, integer, character varying, integer, integer, boolean, character varying[], character varying[])
--DROP FUNCTION cms_treenode_subtree(integer, integer, character varying[], boolean, boolean, integer, character varying, integer, integer, boolean, character varying[], character varying[]);
 
CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id integer, p_user_id integer, p_res_hrids character varying[], p_is_main boolean, p_has_url boolean, p_depth integer, p_where character varying, p_page_num integer, p_page_size integer, p_return_parent boolean, p_placeholders character varying[], p_statuses character varying[])
  RETURNS SETOF tree_nodes AS
$BODY$
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
          tn_rec.resource_status := rec.status;
          RETURN NEXT tn_rec;
        END LOOP;
        RETURN;
      END
      $BODY$
  LANGUAGE 'plpgsql' VOLATILE
 
my_code
execute sql
  end

  def self.down
  end
end
