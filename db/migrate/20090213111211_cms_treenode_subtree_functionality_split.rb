class CmsTreenodeSubtreeFunctionalitySplit < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
      -- ========================================================================================================================
      -- Banned flag in USERS and GROUPS tables
      -- ========================================================================================================================

      ALTER TABLE groups ADD COLUMN banned boolean NOT NULL DEFAULT FALSE;
      ALTER TABLE users ADD COLUMN banned boolean NOT NULL DEFAULT FALSE;

      CREATE OR REPLACE FUNCTION cms_banned_update()
       RETURNS trigger AS
      $BODY$
         BEGIN

      if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then

      if length(rtrim(COALESCE(NEW.reason_of_ban, ''::character varying)::text)) = 0 then
      NEW.banned := false;
      else
      NEW.banned := true;
      end if;

      end if;

             RETURN NEW;

         END;
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      CREATE TRIGGER cms_groups_banned_trigger
       BEFORE INSERT OR UPDATE
       ON groups
       FOR EACH ROW
       EXECUTE PROCEDURE cms_banned_update();

      CREATE TRIGGER cms_users_banned_trigger
       BEFORE INSERT OR UPDATE
       ON users
       FOR EACH ROW
       EXECUTE PROCEDURE cms_banned_update();

      update users set id = id;
      update groups set id = id;

      -- ========================================================================================================================
      -- Create Cache table (just in case)
      -- ========================================================================================================================

      CREATE OR REPLACE VIEW cms_all_treenode_max_user_permission AS
      SELECT r.tree_node_id, gu.user_id, max(r.ac_type) AS max_ac_type
        FROM tree_node_ac_rights r
        JOIN groups g ON r.group_id = g.id AND not g.banned
        JOIN groups_users gu ON g.id = gu.group_id
        JOIN users u ON gu.user_id = u.id AND not u.banned
       GROUP BY r.tree_node_id, gu.user_id;

      CREATE TABLE cms_cache_tree_node_ac_rights
      (
       tree_node_id serial NOT NULL,
       user_id serial NOT NULL,
       ac_type integer NOT NULL,
       CONSTRAINT cms_cache_tree_node_ac_rights_pkey PRIMARY KEY (tree_node_id, user_id)
      )
      WITH (OIDS=FALSE);

      CREATE INDEX cms_cache_tree_node_ac_rights_tn_idx
       ON cms_cache_tree_node_ac_rights
       USING btree
       (tree_node_id);

      CREATE INDEX cms_cache_tree_node_ac_rights_user_idx
       ON cms_cache_tree_node_ac_rights
       USING btree
       (user_id);

      -- ========================================================================================================================
      -- Cache Level functions
      -- ========================================================================================================================

      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_update_group(p_group_id integer)
       RETURNS integer AS
      $BODY$
       BEGIN

       delete from cms_cache_tree_node_ac_rights where user_id in (select user_id from groups_users where group_id = p_group_id);

       INSERT INTO cms_cache_tree_node_ac_rights
         select * from cms_all_treenode_max_user_permission
         where user_id in (select user_id from groups_users where group_id = p_group_id);

       analyze cms_cache_tree_node_ac_rights;

       RETURN 1;
       END
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_update_user(p_user_id integer)
       RETURNS integer AS
      $BODY$
       BEGIN

       delete from cms_cache_tree_node_ac_rights where user_id = p_user_id;

       INSERT INTO cms_cache_tree_node_ac_rights
         select * from cms_all_treenode_max_user_permission
         where user_id = p_user_id;

       analyze cms_cache_tree_node_ac_rights;

       RETURN 1;
       END
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_refresh(f_table boolean)
       RETURNS integer AS
      $BODY$
       BEGIN

       if f_table then
         DROP TABLE IF EXISTS cms_cache_tree_node_ac_rights;
         CREATE TABLE cms_cache_tree_node_ac_rights (
           tree_node_id serial NOT NULL,
           user_id serial NOT NULL,
           ac_type integer NOT NULL,
           CONSTRAINT cms_cache_tree_node_ac_rights_pkey PRIMARY KEY (tree_node_id, user_id));
         CREATE INDEX cms_cache_tree_node_ac_rights_tn_idx ON cms_cache_tree_node_ac_rights USING btree (tree_node_id);
         CREATE INDEX cms_cache_tree_node_ac_rights_user_idx ON cms_cache_tree_node_ac_rights USING btree (user_id);
       end if;

       delete from cms_cache_tree_node_ac_rights;

       INSERT INTO cms_cache_tree_node_ac_rights
         select * from cms_all_treenode_max_user_permission;

       analyze cms_cache_tree_node_ac_rights;

       RETURN 1;
       END
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      -- ========================================================================================================================
      -- Trigger functions
      -- ========================================================================================================================

      CREATE OR REPLACE FUNCTION cms_cache_groups_alter()
       RETURNS trigger AS
      $BODY$
         DECLARE
      l_i integer;
         BEGIN

      if TG_OP = 'DELETE' or (TG_OP = 'UPDATE' and OLD.banned <> NEW.banned) then

      select cms_cache_tree_node_ac_rights_update_group(OLD.id) into l_i;

      end if;

             RETURN NEW;

         END;
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      CREATE OR REPLACE FUNCTION cms_cache_groups_users_alter()
       RETURNS trigger AS
      $BODY$
         DECLARE
      l_i  integer;
      l_id integer;
         BEGIN

      if TG_OP = 'INSERT' then
      l_id := NEW.user_id;
      else
      l_id := OLD.user_id;
      end if;

      select cms_cache_tree_node_ac_rights_update_user(l_id) into l_i;

             RETURN NEW;

         END;
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_alter()
       RETURNS trigger AS
      $BODY$
         DECLARE
      l_i  integer;
      l_id integer;
         BEGIN

      if TG_OP = 'INSERT' then
      l_id := NEW.group_id;
      else
      l_id := OLD.group_id;
      end if;

      select cms_cache_tree_node_ac_rights_update_group(l_id) into l_i;

             RETURN NEW;

         END;
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      CREATE OR REPLACE FUNCTION cms_cache_tree_nodes_alter()
       RETURNS trigger AS
      $BODY$
         DECLARE
      l_i integer;
         BEGIN

      if TG_OP = 'DELETE' then

      delete from cms_cache_tree_node_ac_rights where tree_node_id = OLD.id;

      end if;

             RETURN NEW;

         END;
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      CREATE OR REPLACE FUNCTION cms_cache_users_alter()
       RETURNS trigger AS
      $BODY$
         DECLARE
      l_i integer;
         BEGIN

      if TG_OP = 'DELETE' or (TG_OP = 'UPDATE' and OLD.banned <> NEW.banned) then

      select cms_cache_tree_node_ac_rights_update_user(OLD.id) into l_i;

      end if;

             RETURN NEW;

         END;
      $BODY$
       LANGUAGE 'plpgsql' VOLATILE;

      -- ========================================================================================================================
      -- Triggers
      -- ========================================================================================================================

      CREATE TRIGGER cms_cache_users_trigger
       AFTER INSERT OR UPDATE OR DELETE
       ON users
       FOR EACH ROW
       EXECUTE PROCEDURE cms_cache_users_alter();

      CREATE TRIGGER cms_cache_groups_users_trigger
       AFTER INSERT OR UPDATE OR DELETE
       ON groups_users
       FOR EACH ROW
       EXECUTE PROCEDURE cms_cache_groups_users_alter();

      CREATE TRIGGER cms_cache_groups_trigger
       AFTER INSERT OR UPDATE OR DELETE
       ON groups
       FOR EACH ROW
       EXECUTE PROCEDURE cms_cache_groups_alter();

      CREATE TRIGGER cms_cache_tree_node_ac_rights_trigger
       AFTER INSERT OR UPDATE OR DELETE
       ON tree_node_ac_rights
       FOR EACH ROW
       EXECUTE PROCEDURE cms_cache_tree_node_ac_rights_alter();

      CREATE TRIGGER cms_cache_tree_nodes_trigger
       AFTER DELETE
       ON tree_nodes
       FOR EACH ROW
       EXECUTE PROCEDURE cms_cache_tree_nodes_alter();

      -- ========================================================================================================================
      -- Update cache table
      -- ========================================================================================================================

      select cms_cache_tree_node_ac_rights_refresh(true);

      -- ========================================================================================================================
      -- Main CMS function updates
      -- ========================================================================================================================

      CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id integer, p_user_id integer, p_res_hrids character varying[], p_is_main boolean, p_has_url boolean, p_where character varying, p_page_num integer, p_page_size integer, p_return_parent boolean, p_placeholders character varying[], p_statuses character varying[])
       RETURNS SETOF tree_nodes AS
      $BODY$
               SELECT
                 a.*
               FROM
                 tree_nodes                                     a
                 join resources                                 b on (a.resource_id = b.id)
                 left join cms_cache_tree_node_ac_rights c on (c.tree_node_id = a.id and $2 = c.user_id)
               WHERE
                 (a.parent_id = $1 or (COALESCE($9, false) = true and a.id = $1)) and
                 (($11 is null and b.status = 'PUBLISHED') or ($11 is not null and b.status = ANY($11))) and
         ((b.status = 'PUBLISHED' and c.ac_type > 0) or
                   (b.status = 'DRAFT' and c.ac_type > 1) or
                   (b.status = 'DELETED' and c.ac_type > 2)) and
                 ($5 is null       or a.has_url = $5) and
                 ($4 is null       or a.is_main = $4) and
                 ($3 is null     or b.resource_type_id IN (select id from resource_types where hrid = ANY ($3))) and
                 ($10 is null or a.placeholder = ANY ($10)) and
                 ($6 is null         or a.resource_id IN (select * from cms_cache_resource_properties_where_pipe($6)))
               ORDER BY
                 a.position
               LIMIT
                 COALESCE($8, 25)
               OFFSET
                 COALESCE($7, 0) * COALESCE($8, 25)
           $BODY$
       LANGUAGE 'sql' VOLATILE;

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
                 t.id, t.level, b.status, COALESCE(c.ac_type, 0) as max_ac_type
               FROM
                 connectby('tree_nodes', 'id', 'parent_id', 'position',  cast(p_tn_id AS text), COALESCE(p_depth, 0)) AS t(id int, parent_id int, level integer, position int)
                 join tree_nodes                                a on (t.id = a.id)
                 join resources                                 b on (a.resource_id = b.id)
                 left join cms_cache_tree_node_ac_rights c on (c.tree_node_id = t.id and p_user_id = c.user_id)
               WHERE
                 (p_has_url is null      or a.has_url = p_has_url) and
                 (p_is_main is null      or a.is_main = p_is_main) and
                 (p_res_hrids is null    or b.resource_type_id IN (select id from resource_types where hrid = ANY (p_res_hrids))) and
                 (p_placeholders is null or a.placeholder = ANY (p_placeholders)) and
                 (p_where is null        or a.resource_id IN (select * from cms_cache_resource_properties_where_pipe(p_where)))
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
       LANGUAGE 'plpgsql' VOLATILE;
    my_code
    execute sql
  end

  def self.down
  end
end
