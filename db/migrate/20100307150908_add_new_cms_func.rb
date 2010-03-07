class AddNewCmsFunc < ActiveRecord::Migration
  def self.up
      execute <<-SQL
CREATE OR REPLACE FUNCTION cms_treenode_subtree_order_asc("p_tn_id" integer, "p_user_id" integer, "p_res_hrids" character varying[], "p_is_main" boolean, "p_has_url" boolean, "p_depth" integer, "p_where" character varying, "p_page_num" integer, "p_page_size" integer, "p_return_parent" boolean, "p_placeholders" character varying[], "p_statuses" character varying[], "p_order_by" character varying) RETURNS SETOF tree_nodes AS
$BODY$
	SELECT * FROM
		cms_treenode_subtree($1, $2, $3, $4, $5, $6, $7, 0, 2147483647, $10, $11, $12)
	      ORDER BY
		CASE
			WHEN $13 = 'id' THEN id
			WHEN $13 = 'parent_id' THEN parent_id
			WHEN $13 = 'resource_id' THEN resource_id
			WHEN $13 = 'created_at' THEN EXTRACT(epoch from created_at)
			WHEN $13 = 'updated_at' THEN EXTRACT(epoch from updated_at)
			WHEN $13 = 'tree_nodes_count' THEN tree_nodes_count
			WHEN $13 = 'max_user_permission' THEN max_user_permission
			WHEN $13 = 'is_main' THEN CASE is_main WHEN true THEN 1 ELSE 0 END
			WHEN $13 = 'has_url' THEN CASE has_url WHEN true THEN 1 ELSE 0 END
			WHEN $13 = 'direct_child_count' THEN direct_child_count
			ELSE position
		END ASC
              LIMIT
                COALESCE($9, 25)
              OFFSET
                COALESCE($8, 0) * COALESCE($9, 25)
      $BODY$
  LANGUAGE 'sql' VOLATILE;

CREATE OR REPLACE FUNCTION cms_treenode_subtree_order_desc("p_tn_id" integer, "p_user_id" integer, "p_res_hrids" character varying[], "p_is_main" boolean, "p_has_url" boolean, "p_depth" integer, "p_where" character varying, "p_page_num" integer, "p_page_size" integer, "p_return_parent" boolean, "p_placeholders" character varying[], "p_statuses" character varying[], "p_order_by" character varying) RETURNS SETOF tree_nodes AS
$BODY$
	SELECT * FROM
		cms_treenode_subtree($1, $2, $3, $4, $5, $6, $7, 0, 2147483647, $10, $11, $12)
	      ORDER BY
		CASE
			WHEN $13 = 'id' THEN id
			WHEN $13 = 'parent_id' THEN parent_id
			WHEN $13 = 'resource_id' THEN resource_id
			WHEN $13 = 'created_at' THEN EXTRACT(epoch from created_at)
			WHEN $13 = 'updated_at' THEN EXTRACT(epoch from updated_at)
			WHEN $13 = 'tree_nodes_count' THEN tree_nodes_count
			WHEN $13 = 'max_user_permission' THEN max_user_permission
			WHEN $13 = 'is_main' THEN CASE is_main WHEN true THEN 1 ELSE 0 END
			WHEN $13 = 'has_url' THEN CASE has_url WHEN true THEN 1 ELSE 0 END
			WHEN $13 = 'direct_child_count' THEN direct_child_count
			ELSE position
		END DESC
              LIMIT
                COALESCE($9, 25)
              OFFSET
                COALESCE($8, 0) * COALESCE($9, 25)
      $BODY$
  LANGUAGE 'sql' VOLATILE;

CREATE OR REPLACE FUNCTION cms_treenode_subtree("p_tn_id" integer, "p_user_id" integer, "p_res_hrids" character varying[], "p_is_main" boolean, "p_has_url" boolean, "p_depth" integer, "p_where" character varying, "p_page_num" integer, "p_page_size" integer, "p_return_parent" boolean, "p_placeholders" character varying[], "p_statuses" character varying[], "p_order_by" character varying, "p_order_asc" boolean) RETURNS SETOF tree_nodes AS
$BODY$
	SELECT * FROM cms_treenode_subtree_order_asc($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) WHERE $14 = true
        UNION ALL
	SELECT * FROM cms_treenode_subtree_order_desc($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) WHERE $14 = false

$BODY$
LANGUAGE 'sql' VOLATILE;

      SQL
  end

  def self.down
  end
end
