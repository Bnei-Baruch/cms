class ResetDbFuncsAndAddCache < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
      SET client_encoding = 'UTF8';
      SET standard_conforming_strings = off;
      SET check_function_bodies = false;
      SET client_min_messages = warning;
      SET escape_string_warning = off;

      -- DROP STUFF

      DROP TRIGGER IF EXISTS cms_cache_groups_trigger on groups;
      DROP TRIGGER IF EXISTS cms_cache_groups_users_trigger on groups_users;
      DROP TRIGGER IF EXISTS cms_cache_properties_trigger on properties;
      DROP TRIGGER IF EXISTS cms_cache_resource_properties_trigger on resource_properties;
      DROP TRIGGER IF EXISTS cms_cache_resources_trigger on resources;
      DROP TRIGGER IF EXISTS cms_cache_tree_node_ac_rights_trigger on tree_node_ac_rights;
      DROP TRIGGER IF EXISTS cms_cache_tree_nodes_trigger on tree_nodes;
      DROP TRIGGER IF EXISTS cms_cache_users_trigger on users;
      DROP TRIGGER IF EXISTS cms_groups_banned_trigger on groups;
      DROP TRIGGER IF EXISTS cms_users_banned_trigger on users;
      DROP FUNCTION IF EXISTS cms_cache_groups_alter();
      DROP FUNCTION IF EXISTS cms_cache_groups_users_alter();
      DROP FUNCTION IF EXISTS cms_cache_properties_alter();
      DROP FUNCTION IF EXISTS cms_clean_outdated_pages(timestamp without time zone);
      DROP VIEW IF EXISTS cms_cache_properties_fields;
      DROP VIEW IF EXISTS cms_cache_resource_properties_linear;
      DROP VIEW IF EXISTS cms_util_describe;
      DROP FUNCTION IF EXISTS cms_cache_tree_nodes_alter();
      DROP TABLE IF EXISTS page_maps CASCADE;
      DROP SEQUENCE IF EXISTS page_maps_id_seq CASCADE;
      DROP FUNCTION IF EXISTS cms_get_outdated_pages();

      -- TABLE PAGE MAPS

      CREATE TABLE page_maps
      (
        id serial NOT NULL,
        parent_id integer NOT NULL,
        child_id integer NOT NULL,
        CONSTRAINT page_maps_pk PRIMARY KEY (id),
        CONSTRAINT page_maps_child_fk FOREIGN KEY (child_id)
            REFERENCES tree_nodes (id) MATCH SIMPLE
            ON UPDATE CASCADE ON DELETE CASCADE,
        CONSTRAINT page_maps_parent_fk FOREIGN KEY (parent_id)
            REFERENCES tree_nodes (id) MATCH SIMPLE
            ON UPDATE CASCADE ON DELETE CASCADE
      );

      -- CREATE STUFF

      CREATE FUNCTION cms_cache_groups_alter() RETURNS trigger
          AS $$
          DECLARE
        l_i integer;
          BEGIN

        if TG_OP = 'DELETE' or (TG_OP = 'UPDATE' and OLD.banned <> NEW.banned) then

          select cms_cache_tree_node_ac_rights_update_group(OLD.id) into l_i;

        end if;

              RETURN NEW;

          END;
      $$
      LANGUAGE plpgsql;

      CREATE FUNCTION cms_cache_groups_users_alter() RETURNS trigger
          AS $$
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
      $$
      LANGUAGE plpgsql;


      CREATE FUNCTION cms_cache_properties_alter() RETURNS trigger
          AS $$
          DECLARE
            l_fname  varchar;
            l_ftype  varchar;
            l_etype  varchar;
            l_exists integer;
          BEGIN

        if TG_OP = 'INSERT' then
          SELECT cms_cache_property_field_name(NEW.hrid, NEW.field_type), cms_cache_property_field_type(NEW.field_type) into l_fname, l_ftype;
          select count(*) into l_exists from cms_util_describe where "Table" = 'cms_cache_resource_properties' and "Field" = l_fname;

          if l_exists > 0 then
            select "Type" into l_etype from cms_util_describe where "Table" = 'cms_cache_resource_properties' and "Field" = l_fname;
            if l_etype <> l_ftype then
              RAISE EXCEPTION 'Existing % field type % does not match new type % in cache table', l_fname, l_etype, lftype;
            end if;
          else
            execute 'ALTER TABLE "cms_cache_resource_properties" ADD COLUMN ' || l_fname || ' ' || l_ftype;
          end if;
        elsif TG_OP = 'DELETE' then
          SELECT cms_cache_property_field_name(OLD.hrid, OLD.field_type), cms_cache_property_field_type(OLD.field_type) into l_fname, l_ftype;
          SELECT count(*) into l_exists from cms_cache_properties_fields where field_name = l_fname and field_type = l_ftype;

          if l_exists = 0 then
            execute 'ALTER TABLE "cms_cache_resource_properties" DROP COLUMN ' || l_fname;
          end if;
        elsif TG_OP = 'UPDATE' and OLD.hrid <> NEW.hrid then
          RAISE EXCEPTION 'Field properties.hrid can not be updated because of the cache table';
        end if;

              RETURN NEW;

          END;
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_properties_field_list(p_with_type boolean) RETURNS character varying
          AS $$
            DECLARE
              l_ret   varchar := 'resource_id';
              l_fn    varchar;
              l_ft    varchar;
            BEGIN

              if p_with_type then
                l_ret := l_ret || ' integer';
              end if;
              for l_fn, l_ft in SELECT p.field_name, p.field_type FROM cms_cache_properties_fields p ORDER BY p.field_name
        loop
                l_ret := l_ret || ',' || l_fn;
                if p_with_type then
                  l_ret := l_ret || ' ' || l_ft;
                end if;
              end loop;

              RETURN l_ret;

            END
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_property_field_name(p_hrid character varying, p_type character varying) RETURNS character varying
          AS $$
      declare
        l_type varchar := cms_cache_property_field_type(p_type);
      begin
        return (lower(substring(l_type::text, '^.')) || '_') || lower(p_hrid);
      end
      $$
      LANGUAGE plpgsql STABLE;

      CREATE OR REPLACE FUNCTION cms_cache_outdate_page(p_resource_id integer, p_tree_node_id integer) RETURNS integer
          AS $$
      begin
        -- Outdated pages
        INSERT INTO
          cms_cache_outdated_pages
          (page_id)
          SELECT distinct
            parent_id
          FROM
            page_maps
          WHERE
            ((child_id in (select id from tree_nodes where resource_id = p_resource_id) and p_resource_id is not null) or
            (child_id = p_tree_node_id and p_tree_node_id is not null)) and
            parent_id not in (select page_id from cms_cache_outdated_pages);

        delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);

        return 1;
      end
      $$
      LANGUAGE plpgsql VOLATILE;

      CREATE OR REPLACE FUNCTION cms_cache_property_field_type(p_type character varying) RETURNS character varying
          AS $$
      begin
        if p_type = 'String' THEN return 'text'; end if;
        if p_type = 'Number' THEN return 'numeric'; end if;
        if p_type = 'Plaintext' THEN return 'text'; end if;
        if p_type = 'File' THEN return 'text'; end if;
        return lower(p_type);
      end
      $$
      LANGUAGE plpgsql STABLE;

      CREATE OR REPLACE FUNCTION cms_banned_update() RETURNS trigger AS
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


      CREATE OR REPLACE FUNCTION cms_cache_resource_properties_alter() RETURNS trigger
          AS $$
          DECLARE
        l_res_id integer;
        l_rows integer;
          BEGIN

        if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
          l_res_id := NEW.resource_id;
        elsif TG_OP = 'DELETE' then
          l_res_id := OLD.resource_id;
        end if;

        delete from cms_cache_resource_properties where resource_id = l_res_id;
        execute 'insert into cms_cache_resource_properties (' || cms_cache_properties_field_list(false) || ')
          SELECT * FROM crosstab(
            ''select resource_id, field_name, value from cms_cache_resource_properties_linear where resource_id = ' || cast(l_res_id as varchar) || ' order by 1, 2'',
            ''select distinct field_name from cms_cache_properties_fields order by field_name'')
          AS ct(' || cms_cache_properties_field_list(true) || ')';

        INSERT INTO
          cms_cache_outdated_pages
          (page_id)
          SELECT distinct
            parent_id
          FROM
            page_maps
          WHERE
            child_id in (select id from tree_nodes where resource_id = l_res_id) and
            parent_id not in (select page_id from cms_cache_outdated_pages);

        delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);


              RETURN NEW;

          END;
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_resource_properties_refresh(f_table boolean) RETURNS integer
          AS $$
        BEGIN

        if f_table then
          DROP TABLE IF EXISTS cms_cache_resource_properties;
          execute 'CREATE TABLE cms_cache_resource_properties (' || cms_cache_properties_field_list(true) || ')';
          ALTER TABLE "cms_cache_resource_properties" ADD CONSTRAINT cms_resource_properties_cache_pk PRIMARY KEY (resource_id);
        end if;

        delete from "cms_cache_resource_properties";

        execute 'INSERT INTO cms_cache_resource_properties (' || cms_cache_properties_field_list(false) || ')
          SELECT * FROM crosstab(
            ''select resource_id, field_name, value from cms_cache_resource_properties_linear'',
            ''select distinct field_name from cms_cache_properties_fields order by field_name'')
          AS ct(' || cms_cache_properties_field_list(true) || ')';

        analyze cms_cache_resource_properties;

        RETURN 1;
        END
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_resource_properties_where_pipe(p_where character varying) RETURNS SETOF integer
          AS $$
            DECLARE
              c refcursor;
              i integer;
            BEGIN

              -- if no where - give up
              if p_where is null or p_where = '' then
                return;
              end if;

              -- iterate through results
              open c for EXECUTE 'SELECT distinct resource_id FROM cms_cache_resource_properties where (' || p_where || ')';
              loop
                fetch c into i;
                exit when NOT FOUND;
                return next i;
              end loop;
              close c;
              return;
            END
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_resources_alter() RETURNS trigger
          AS $$
          DECLARE
        l_i integer;
        l_rows integer;
          BEGIN

        if TG_OP = 'INSERT' then
          insert into cms_cache_resource_properties (resource_id) values (NEW.id);
          l_i := NEW.id;
        elsif TG_OP = 'DELETE' then
          delete from cms_cache_resource_properties where resource_id = OLD.id;
          l_i := OLD.id;
        elseif TG_OP = 'UPDATE' then
          l_i := NEW.id;
        end if;

        INSERT INTO
          cms_cache_outdated_pages
          (page_id)
          SELECT distinct
            parent_id
          FROM
            page_maps
          WHERE
            child_id in (select id from tree_nodes where resource_id = l_i) and
            parent_id not in (select page_id from cms_cache_outdated_pages);

        delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);


              RETURN NEW;

          END;
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_alter() RETURNS trigger
          AS $$
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
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_refresh(f_table boolean) RETURNS integer
          AS $$
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
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_update_group(p_group_id integer) RETURNS integer
          AS $$
        BEGIN

        delete from cms_cache_tree_node_ac_rights where user_id in (select user_id from groups_users where group_id = p_group_id);

        INSERT INTO cms_cache_tree_node_ac_rights
          select * from cms_all_treenode_max_user_permission
          where user_id in (select user_id from groups_users where group_id = p_group_id);

        analyze cms_cache_tree_node_ac_rights;

        RETURN 1;
        END
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_tree_node_ac_rights_update_user(p_user_id integer) RETURNS integer
          AS $$
        BEGIN

        delete from cms_cache_tree_node_ac_rights where user_id = p_user_id;

        INSERT INTO cms_cache_tree_node_ac_rights
          select * from cms_all_treenode_max_user_permission
          where user_id = p_user_id;

        analyze cms_cache_tree_node_ac_rights;

        RETURN 1;
        END
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_cache_tree_nodes_alter() RETURNS trigger
          AS $$
          DECLARE
        l_i integer;
        l_rows integer;
          BEGIN

        if TG_OP = 'DELETE' then
          delete from cms_cache_tree_node_ac_rights where tree_node_id = OLD.id;
          l_i := OLD.id;
        else
          l_i := NEW.id;
        end if;

        INSERT INTO
          cms_cache_outdated_pages
          (page_id)
          SELECT distinct
            parent_id
          FROM
            page_maps
          WHERE
            child_id = l_i and
            parent_id not in (select page_id from cms_cache_outdated_pages);

        delete from page_maps where parent_id in (select page_id from cms_cache_outdated_pages);


              RETURN NEW;

          END;
      $$
      LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION cms_cache_users_alter() RETURNS trigger
          AS $$
          DECLARE
        l_i integer;
          BEGIN

        if TG_OP = 'DELETE' or (TG_OP = 'UPDATE' and OLD.banned <> NEW.banned) then

          select cms_cache_tree_node_ac_rights_update_user(OLD.id) into l_i;

        end if;

              RETURN NEW;

          END;
      $$
      LANGUAGE plpgsql;

      CREATE OR REPLACE FUNCTION cms_clean_outdated_pages(p_timestamp varchar) RETURNS integer
          AS $$
      DECLARE
            r integer;
      BEGIN
            delete from cms_cache_outdated_pages where date = p_timestamp;
            RETURN 1;
            END
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id integer, p_user_id integer, p_res_hrids character varying[], p_is_main boolean, p_has_url boolean, p_depth integer, p_where character varying, p_page_num integer, p_page_size integer, p_return_parent boolean, p_placeholders character varying[], p_statuses character varying[]) RETURNS SETOF tree_nodes
          AS $$
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
      $$
      LANGUAGE plpgsql;


      CREATE OR REPLACE FUNCTION cms_treenode_subtree(p_tn_id integer, p_user_id integer, p_res_hrids character varying[], p_is_main boolean, p_has_url boolean, p_where character varying, p_page_num integer, p_page_size integer, p_return_parent boolean, p_placeholders character varying[], p_statuses character varying[]) RETURNS SETOF tree_nodes
          AS $_$
                SELECT
                  a.*
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
      $_$
      LANGUAGE sql;

      CREATE OR REPLACE FUNCTION cms_cache_outdated_pages_refresh(f_table boolean)
        RETURNS integer AS
      $BODY$begin

        if f_table then

        DROP TABLE IF EXISTS cms_cache_outdated_pages;

        CREATE TABLE cms_cache_outdated_pages
        (
          page_id integer NOT NULL,
          date varchar(100) NOT NULL DEFAULT CAST(now() as varchar),
          CONSTRAINT cms_cache_outdated_pages_pk PRIMARY KEY (page_id)
        )
          WITH (OIDS=FALSE);
        else
          delete from cms_cache_outdated_pages;
        end if;


        return 1;

      end;
      $BODY$
        LANGUAGE 'plpgsql' VOLATILE;

      CREATE VIEW cms_cache_properties_fields AS
        SELECT DISTINCT
          cms_cache_property_field_name(p.hrid, p.field_type) AS field_name,
          cms_cache_property_field_type(p.field_type) AS field_type
        FROM
          properties p;

      CREATE VIEW cms_cache_resource_properties_linear AS
          SELECT rp.resource_id, cms_cache_property_field_name(p.hrid, p.field_type) AS field_name, p.hrid, rp.property_id, CASE p.field_type WHEN 'String'::text THEN (rp.string_value)::text WHEN 'Text'::text THEN rp.text_value WHEN 'Plaintext'::text THEN rp.text_value WHEN 'Boolean'::text THEN (rp.boolean_value)::text WHEN 'Number'::text THEN (rp.number_value)::text WHEN 'Date'::text THEN ((rp.timestamp_value)::date)::text WHEN 'Timestamp'::text THEN (rp.timestamp_value)::text WHEN 'File'::text THEN (a.filename)::text ELSE NULL::text END AS value FROM ((resource_properties rp JOIN properties p ON ((rp.property_id = p.id))) LEFT JOIN attachments a ON ((a.resource_property_id = rp.id))) ORDER BY rp.resource_id, p.hrid;


      CREATE VIEW cms_util_describe AS
          SELECT pg_class.relname AS "Table", pg_attribute.attname AS "Field", CASE pg_type.typname WHEN 'int2'::name THEN 'smallint'::name WHEN 'int4'::name THEN 'int'::name WHEN 'int8'::name THEN 'bigint'::name WHEN 'varchar'::name THEN ((('varchar('::text || (pg_attribute.atttypmod - 4)) || ')'::text))::name ELSE pg_type.typname END AS "Type", CASE WHEN pg_attribute.attnotnull THEN ''::text ELSE 'YES'::text END AS "Null", CASE pg_type.typname WHEN 'varchar'::name THEN "substring"(pg_attrdef.adsrc, '^''(.*)''.*$'::text) ELSE pg_attrdef.adsrc END AS "Default" FROM (((pg_class JOIN pg_attribute ON ((pg_class.oid = pg_attribute.attrelid))) JOIN pg_type ON ((pg_attribute.atttypid = pg_type.oid))) LEFT JOIN pg_attrdef ON (((pg_class.oid = pg_attrdef.adrelid) AND (pg_attribute.attnum = pg_attrdef.adnum)))) WHERE ((pg_attribute.attnum >= 1) AND (NOT pg_attribute.attisdropped)) ORDER BY pg_attribute.attnum;


      CREATE TRIGGER cms_cache_groups_trigger
          AFTER INSERT OR DELETE OR UPDATE ON groups
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_groups_alter();

      CREATE TRIGGER cms_cache_groups_users_trigger
          AFTER INSERT OR DELETE OR UPDATE ON groups_users
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_groups_users_alter();

      CREATE TRIGGER cms_cache_properties_trigger
          AFTER INSERT OR DELETE OR UPDATE ON properties
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_properties_alter();

      CREATE TRIGGER cms_cache_resource_properties_trigger
          AFTER INSERT OR DELETE OR UPDATE ON resource_properties
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_resource_properties_alter();

      CREATE TRIGGER cms_cache_resources_trigger
          AFTER INSERT OR DELETE OR UPDATE ON resources
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_resources_alter();

      CREATE TRIGGER cms_cache_tree_node_ac_rights_trigger
          AFTER INSERT OR DELETE OR UPDATE ON tree_node_ac_rights
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_tree_node_ac_rights_alter();

      CREATE TRIGGER cms_cache_tree_nodes_trigger
          AFTER INSERT OR DELETE OR UPDATE ON tree_nodes
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_tree_nodes_alter();

      CREATE TRIGGER cms_cache_users_trigger
          AFTER INSERT OR DELETE OR UPDATE ON users
          FOR EACH ROW
          EXECUTE PROCEDURE cms_cache_users_alter();

      CREATE TRIGGER cms_groups_banned_trigger
          BEFORE INSERT OR UPDATE ON groups
          FOR EACH ROW
          EXECUTE PROCEDURE cms_banned_update();

      CREATE TRIGGER cms_users_banned_trigger
          BEFORE INSERT OR UPDATE ON users
          FOR EACH ROW
          EXECUTE PROCEDURE cms_banned_update();

      -- Refresh cache stuff

      select
        cms_cache_outdated_pages_refresh(true) as cms_cache_outdated_pages_refresh;
      select
        cms_cache_resource_properties_refresh(true) as cms_cache_resource_properties_refresh;
      select
        cms_cache_tree_node_ac_rights_refresh(true) as cms_cache_tree_node_ac_rights_refresh;

      -- Update function that depends on cache tables

      CREATE OR REPLACE FUNCTION cms_get_outdated_pages() RETURNS SETOF cms_cache_outdated_pages
          AS $$
      DECLARE
            rec cms_cache_outdated_pages%rowtype;
      BEGIN
            update cms_cache_outdated_pages set date = CAST(NOW() as varchar);
            for rec in select * from cms_cache_outdated_pages loop
              RETURN NEXT rec;
            end loop;
            RETURN;
            END
      $$
      LANGUAGE plpgsql;
    my_code
    execute sql
  end

  def self.down
  end
end
