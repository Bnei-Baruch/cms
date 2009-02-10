class ReplaceCmsTreenodeSubtreeFunctionality < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
        SET client_encoding = 'UTF8';
        SET standard_conforming_strings = off;
        SET check_function_bodies = false;
        SET client_min_messages = warning;
        SET escape_string_warning = off;

        SET search_path = cms_test, pg_catalog;
        SET default_tablespace = '';
        SET default_with_oids = false;

        --
        -- TOC entry 62 (class 1255 OID 40273)
        -- Dependencies: 6 428
        -- Name: cms_cache_property_field_name(character varying, character varying); Type: FUNCTION; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE FUNCTION cms_cache_property_field_name(p_hrid character varying, p_type character varying) RETURNS character varying
            AS $$
        declare
          l_type varchar := cms_cache_property_field_type(p_type);
        begin
          return (lower(substring(l_type::text, '^.')) || '_') || lower(p_hrid);
        end
        $$
            LANGUAGE plpgsql STABLE;

        --
        -- TOC entry 60 (class 1255 OID 40272)
        -- Dependencies: 6 428
        -- Name: cms_cache_property_field_type(character varying); Type: FUNCTION; Schema: cms_test; Owner: -
        --

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

        --
        -- TOC entry 1643 (class 1259 OID 41824)
        -- Dependencies: 1724 6
        -- Name: cms_cache_properties_fields; Type: VIEW; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE VIEW cms_cache_properties_fields AS
            SELECT DISTINCT p.hrid, cms_cache_property_field_name(p.hrid, p.field_type) AS field_name, cms_cache_property_field_type(p.field_type) AS field_type FROM properties p ORDER BY p.hrid, cms_cache_property_field_name(p.hrid, p.field_type), cms_cache_property_field_type(p.field_type);

        --
        -- TOC entry 1645 (class 1259 OID 42357)
        -- Dependencies: 1725 6
        -- Name: cms_cache_resource_properties_linear; Type: VIEW; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE VIEW cms_cache_resource_properties_linear AS
            SELECT rp.resource_id, p.hrid, rp.property_id, CASE p.field_type WHEN 'String'::text THEN (rp.string_value)::text WHEN 'Text'::text THEN rp.text_value WHEN 'Plaintext'::text THEN rp.text_value WHEN 'Boolean'::text THEN (rp.boolean_value)::text WHEN 'Number'::text THEN (rp.number_value)::text WHEN 'Date'::text THEN ((rp.timestamp_value)::date)::text WHEN 'Timestamp'::text THEN (rp.timestamp_value)::text WHEN 'File'::text THEN (a.filename)::text ELSE NULL::text END AS value FROM ((resource_properties rp JOIN properties p ON ((rp.property_id = p.id))) LEFT JOIN attachments a ON ((a.resource_property_id = rp.id))) ORDER BY rp.resource_id, p.hrid;

        --
        -- TOC entry 1642 (class 1259 OID 40238)
        -- Dependencies: 1723 6
        -- Name: cms_util_describe; Type: VIEW; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE VIEW cms_util_describe AS
            SELECT pg_class.relname AS "Table", pg_attribute.attname AS "Field", CASE pg_type.typname WHEN 'int2'::name THEN 'smallint'::name WHEN 'int4'::name THEN 'int'::name WHEN 'int8'::name THEN 'bigint'::name WHEN 'varchar'::name THEN ((('varchar('::text || (pg_attribute.atttypmod - 4)) || ')'::text))::name ELSE pg_type.typname END AS "Type", CASE WHEN pg_attribute.attnotnull THEN ''::text ELSE 'YES'::text END AS "Null", CASE pg_type.typname WHEN 'varchar'::name THEN "substring"(pg_attrdef.adsrc, '^''(.*)''.*$'::text) ELSE pg_attrdef.adsrc END AS "Default" FROM (((pg_class JOIN pg_attribute ON ((pg_class.oid = pg_attribute.attrelid))) JOIN pg_type ON ((pg_attribute.atttypid = pg_type.oid))) LEFT JOIN pg_attrdef ON (((pg_class.oid = pg_attrdef.adrelid) AND (pg_attribute.attnum = pg_attrdef.adnum)))) WHERE ((pg_attribute.attnum >= 1) AND (NOT pg_attribute.attisdropped)) ORDER BY pg_attribute.attnum;

        --
        -- TOC entry 63 (class 1255 OID 41823)
        -- Dependencies: 6 428
        -- Name: cms_cache_properties_alter(); Type: FUNCTION; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE FUNCTION cms_cache_properties_alter() RETURNS trigger
            AS $$
            DECLARE
              l_fname  varchar;
              l_ftype  varchar;
              l_etype  varchar;
              l_exists integer;
            BEGIN

          if TG_OP = 'INSERT' then

            SELECT cms_cache_property_field_name(NEW.hrid, NEW.field_type), cms_cache_property_field_type(NEW.field_type) into l_fname, l_ftype;
            select count(*) into l_exists from cms_cache_describe where "Table" = 'cms_cache_resource_properties' and "Field" = l_fname;

            if l_exists > 0 then
              select "Type" into l_etype from cms_describe where "Table" = 'cms_cache_resource_properties' and "Field" = l_fname;
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


        --
        -- TOC entry 59 (class 1255 OID 27524)
        -- Dependencies: 6 428
        -- Name: cms_cache_properties_field_list(); Type: FUNCTION; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE FUNCTION cms_cache_properties_field_list() RETURNS character varying
            AS $$
              DECLARE
                l_ret   varchar := 'resource_id integer';
                l_f     varchar;
                l_h     varchar;
              BEGIN
                for l_h, l_f in

          SELECT p.hrid, ', ' || p.field_name || ' ' || p.field_type FROM cms_cache_properties_fields p ORDER BY p.hrid, p.field_name, p.field_type
                loop
                  l_ret := l_ret || l_f;
                end loop;

                RETURN l_ret;

              END
              $$
            LANGUAGE plpgsql;


        --
        -- TOC entry 65 (class 1255 OID 42354)
        -- Dependencies: 6 428
        -- Name: cms_cache_resource_properties_alter(); Type: FUNCTION; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE FUNCTION cms_cache_resource_properties_alter() RETURNS trigger
            AS $$
          DECLARE
          l_new_res_id integer := 0;
          l_old_res_id integer := 0;
          l_res_id integer;
            BEGIN

          if TG_OP = 'INSERT' then

            l_new_res_id := NEW.resource_id;

          elsif TG_OP = 'UPDATE' then

            l_new_res_id := NEW.resource_id;
            if NEW.resource_id <> OLD.resource_id then
              l_old_res_id := OLD.resource_id;
            end if;

          elsif TG_OP = 'DELETE' then

            l_old_res_id := OLD.resource_id;

          end if;

          if l_new_res_id > 0 then

            l_res_id := l_new_res_id;
            delete from cms_cache_resource_properties where resource_id = l_res_id;
            execute 'insert into cms_cache_resource_properties
              SELECT * FROM (
              SELECT * FROM crosstab(
                ''select resource_id, hrid, value from cms_cache_resource_properties_linear where resource_id = ' || cast(l_res_id as varchar) || ' order by 1, 2'',
                ''select distinct p.hrid from properties p order by 1'')
              AS ct(' || cms_cache_properties_field_list() || ')) r';

          end if;

          if l_old_res_id > 0 then

            l_res_id := l_old_res_id;
            delete from cms_cache_resource_properties where resource_id = l_res_id;
            execute 'insert into cms_cache_resource_properties
              SELECT * FROM (
              SELECT * FROM crosstab(
                ''select resource_id, hrid, value from cms_cache_resource_properties_linear where resource_id = ' || cast(l_res_id as varchar) || ' order by 1, 2'',
                ''select distinct p.hrid from properties p order by 1'')
              AS ct(' || cms_cache_properties_field_list() || ')) r';

          end if;


                RETURN NEW;

            END;
        $$
            LANGUAGE plpgsql;


        --
        -- TOC entry 57 (class 1255 OID 38713)
        -- Dependencies: 6 428
        -- Name: cms_cache_resource_properties_refresh(boolean); Type: FUNCTION; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE FUNCTION cms_cache_resource_properties_refresh(f_table boolean) RETURNS integer
            AS $$
          BEGIN

          if f_table then
            DROP TABLE IF EXISTS cms_cache_resource_properties;
            execute 'CREATE TABLE cms_cache_resource_properties (' || cms_cache_properties_field_list() || ')';
            ALTER TABLE "cms_cache_resource_properties" ADD CONSTRAINT cms_resource_properties_cache_pk PRIMARY KEY (resource_id);
          end if;

          delete from "cms_cache_resource_properties";

          execute 'INSERT INTO cms_cache_resource_properties
            SELECT * FROM (
            SELECT * FROM crosstab(''select resource_id, hrid, value from cms_cache_resource_properties_linear order by 1, 2'', ''select distinct p.hrid from properties p order by 1'')
            AS ct(' || cms_cache_properties_field_list() || ')) r';

          analyze cms_cache_resource_properties;

          RETURN 1;
          END
        $$
            LANGUAGE plpgsql;


        --
        -- TOC entry 54 (class 1255 OID 27527)
        -- Dependencies: 6 428
        -- Name: cms_cache_resource_properties_where_pipe(character varying); Type: FUNCTION; Schema: cms_test; Owner: -
        --

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


        --
        -- TOC entry 64 (class 1255 OID 42352)
        -- Dependencies: 6 428
        -- Name: cms_cache_resources_alter(); Type: FUNCTION; Schema: cms_test; Owner: -
        --

        CREATE OR REPLACE FUNCTION cms_cache_resources_alter() RETURNS trigger
            AS $$
            BEGIN

          if TG_OP = 'INSERT' then

            insert into cms_cache_resource_properties (resource_id) values (NEW.id);

          elsif TG_OP = 'DELETE' then

            delete from cms_cache_resource_properties where resource_id = NEW.id;

          end if;

                RETURN NEW;

            END;
        $$
            LANGUAGE plpgsql;


        --
        -- TOC entry 58 (class 1255 OID 40236)
        -- Dependencies: 6 428 340
        -- Name: cms_treenode_subtree(integer, integer, character varying[], boolean, boolean, integer, character varying, integer, integer, boolean, character varying[], character varying[]); Type: FUNCTION; Schema: cms_test; Owner: -
        --

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

        --
        -- TOC entry 2043 (class 2620 OID 42351)
        -- Dependencies: 1611 63
        -- Name: cms_cache_properties_trigger; Type: TRIGGER; Schema: cms_test; Owner: -
        --

        CREATE TRIGGER cms_cache_properties_trigger
            AFTER INSERT OR DELETE OR UPDATE ON properties
            FOR EACH ROW
            EXECUTE PROCEDURE cms_cache_properties_alter();


        --
        -- TOC entry 2044 (class 2620 OID 42355)
        -- Dependencies: 1612 65
        -- Name: cms_cache_resource_properties_trigger; Type: TRIGGER; Schema: cms_test; Owner: -
        --

        CREATE TRIGGER cms_cache_resource_properties_trigger
            AFTER INSERT OR DELETE OR UPDATE ON resource_properties
            FOR EACH ROW
            EXECUTE PROCEDURE cms_cache_resource_properties_alter();


        --
        -- TOC entry 2045 (class 2620 OID 42353)
        -- Dependencies: 64 1625
        -- Name: cms_cache_resources_trigger; Type: TRIGGER; Schema: cms_test; Owner: -
        --

        CREATE TRIGGER cms_cache_resources_trigger
            AFTER INSERT OR DELETE ON resources
            FOR EACH ROW
            EXECUTE PROCEDURE cms_cache_resources_alter();

        --
        -- Populating cache data
        --
        select cms_cache_resource_properties_refresh(true);
    my_code
    execute sql
  end

  def self.down
  end
end
