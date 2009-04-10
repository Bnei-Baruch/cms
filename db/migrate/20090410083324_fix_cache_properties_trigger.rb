class FixCachePropertiesTrigger < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    CREATE OR REPLACE FUNCTION cms_cache_properties_alter()
      RETURNS trigger AS
    $BODY$
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
                  RAISE EXCEPTION 'Existing % field type % does not match new type % in cache table', l_fname, l_etype, l_ftype;
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
          $BODY$
      LANGUAGE 'plpgsql' VOLATILE;
 
     my_code
    execute sql

  end

  def self.down
  end
end
