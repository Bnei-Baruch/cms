class GetTreeWithChildrenCount < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
      ALTER TABLE tree_nodes ADD COLUMN direct_child_count bigint;
      ALTER TABLE tree_nodes ADD CONSTRAINT direct_child_count_ck CHECK (direct_child_count is NULL);

      CREATE OR REPLACE FUNCTION cms_treenode_direct_children(

        p_tn_id integer,                        -- $1
        p_user_id integer,                      -- $2
        p_res_hrids character varying[],        -- $3
        p_is_main boolean,                      -- $4
        p_has_url boolean,                      -- $5
        p_placeholders character varying[],     -- $6
        p_statuses character varying[]          -- $7

        ) RETURNS bigint AS
      $BODY$

        SELECT
          count(a.*)
        FROM
          tree_nodes                                     a
          join resources                                 b on (a.resource_id = b.id)
          left join cms_cache_tree_node_ac_rights c on (c.tree_node_id = a.id and $2 = c.user_id)
        WHERE
          a.parent_id = $1 and
          (($7 is null and b.status = 'PUBLISHED') or ($7 is not null and b.status = ANY($7))) and
                ((b.status = 'PUBLISHED' and c.ac_type > 0) or
            (b.status = 'DRAFT' and c.ac_type > 1) or
            (b.status = 'DELETED' and c.ac_type > 2)) and
          ($5 is null      		or a.has_url = $5) and
          ($4 is null      		or a.is_main = $4) and
          ($3 is null    		or b.resource_type_id IN (select id from resource_types where hrid = ANY ($3))) and
          ($6 is null 		or a.placeholder = ANY ($6))

      $BODY$
        LANGUAGE 'sql' VOLATILE;

      DROP FUNCTION cms_treenode_subtree(integer, integer, character varying[], boolean, boolean, character varying, integer, integer, boolean, character varying[], character varying[]);

      CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id integer, p_user_id integer, p_res_hrids character varying[], p_is_main boolean, p_has_url boolean, p_where character varying, p_page_num integer, p_page_size integer, p_return_parent boolean, p_placeholders character varying[], p_statuses character varying[], p_child_count boolean)
        RETURNS SETOF tree_nodes AS
      $BODY$
                      SELECT
                        a.id,
                        a.parent_id,
                        a.resource_id,
                        a."position",
                        a.node_type,
                        a.permalink,
            a.created_at,
            a.updated_at,
            a.is_main,
            a.tree_nodes_count,
            a.has_url,
            a.placeholder,
            a.max_user_permission,
            a.resource_status,
            CASE
              WHEN $12 = true THEN cms_treenode_direct_children(a.id, $2, $3, $4, $5, $10, $11)
              ELSE a.direct_child_count
                        END
                      FROM
                        tree_nodes                                     a
                        join resources                                 b on (a.resource_id = b.id)
                        left join cms_cache_tree_node_ac_rights c on (c.tree_node_id = a.id and $2 = c.user_id)
                      WHERE
                        (a.parent_id = $1		or (COALESCE($9, false) = true and a.id = $1)) and
                        (($11 is null and b.status = 'PUBLISHED') or ($11 is not null and b.status = ANY($11))) and
                  ((b.status = 'PUBLISHED' and c.ac_type > 0) or
                          (b.status = 'DRAFT' and c.ac_type > 1) or
                          (b.status = 'DELETED' and c.ac_type > 2)) and
                        ($5 is null      		or a.has_url = $5) and
                        ($4 is null      		or a.is_main = $4) and
                        ($3 is null    		or b.resource_type_id IN (select id from resource_types where hrid = ANY ($3))) and
                        ($10 is null 		or a.placeholder = ANY ($10)) and
                        ($6 is null        		or a.resource_id IN (select * from cms_cache_resource_properties_where_pipe($6)))
                      ORDER BY
                        a.position
                      LIMIT
                        COALESCE($8, 25)
                      OFFSET
                        COALESCE($7, 0) * COALESCE($8, 25)
            $BODY$
        LANGUAGE 'sql' VOLATILE;
    my_code
    execute sql
  end

  def self.down
  end
end
