class IndicesAndConstraints < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
      ALTER TABLE associations ADD CONSTRAINT association_resource_type_fk FOREIGN KEY (resource_type_id) REFERENCES resource_types (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_association_resource_type_fk ON associations(resource_type_id);

      ALTER TABLE attachments ADD CONSTRAINT attachments_resource_properties_fk FOREIGN KEY (resource_property_id) REFERENCES resource_properties (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      CREATE INDEX groups_reason_of_ban_idx
        ON groups
        USING btree
        (reason_of_ban)
        WHERE reason_of_ban IS NULL OR length(reason_of_ban::text) = 0;

      ALTER TABLE list_values ADD CONSTRAINT list_values_lists_fk FOREIGN KEY (list_id) REFERENCES lists (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_list_values_lists_fk ON list_values(list_id);

      ALTER TABLE lists ADD CONSTRAINT lists_properties_fk FOREIGN KEY (property_id) REFERENCES properties (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_lists_properties_fk ON lists(property_id);

      ALTER TABLE lists ADD CONSTRAINT lists_resource_types_fk FOREIGN KEY (resource_type_id) REFERENCES resource_types (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_lists_resource_types_fk ON lists(resource_type_id);

      CREATE UNIQUE INDEX properties_name_type_id_idx
         ON properties (name, id, field_type);

      CREATE INDEX properties_field_type_idx
         ON properties (field_type);

      ALTER TABLE properties ADD CONSTRAINT properties_resource_type_fk FOREIGN KEY (resource_type_id) REFERENCES resource_types (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_properties_resource_type_fk ON properties(resource_type_id);

      ALTER TABLE resource_properties ADD CONSTRAINT resource_properties_resources_fk FOREIGN KEY (resource_id) REFERENCES resources (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE resource_properties ADD CONSTRAINT resource_properties_properties_fk FOREIGN KEY (property_id) REFERENCES properties (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE resource_properties ADD CONSTRAINT resource_properties_attachments_fk FOREIGN KEY (attachment_id) REFERENCES attachments (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE resource_types_websites ADD CONSTRAINT resource_types_websites_resource_types_fk FOREIGN KEY (resource_type_id) REFERENCES resource_types (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE resource_types_websites ADD CONSTRAINT resource_types_websites_websites_fk FOREIGN KEY (website_id) REFERENCES websites (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE resources ADD CONSTRAINT resources_resource_types_fk FOREIGN KEY (resource_type_id) REFERENCES resource_types (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_resources_resource_types_fk ON resources(resource_type_id);

      CREATE INDEX resources_status_idx
         ON resources USING hash (status);

      ALTER TABLE resource_types_websites ADD CONSTRAINT resource_types_website_pk PRIMARY KEY (resource_type_id, website_id);

      ALTER TABLE resources_websites ADD CONSTRAINT resource_websites_pk PRIMARY KEY (resource_id, website_id);

      ALTER TABLE resources_websites ADD CONSTRAINT resources_websites_resources_fk FOREIGN KEY (resource_id) REFERENCES resources (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      ALTER TABLE resources_websites ADD CONSTRAINT resources_websites_websites_fk FOREIGN KEY (website_id) REFERENCES websites (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;

      CREATE INDEX tree_node_ac_rights_idx
         ON tree_node_ac_rights USING hash (ac_type);

      ALTER TABLE tree_nodes ADD CONSTRAINT tree_nodes_resources_fk FOREIGN KEY (resource_id) REFERENCES resources (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_tree_nodes_resources_fk ON tree_nodes(resource_id);

      CREATE INDEX fki_tree_nodes_parent_fk ON tree_nodes(parent_id);

      CREATE INDEX tree_nodes_permalink_idx
         ON tree_nodes (permalink);

      CREATE INDEX tree_nodes_is_main_idx
         ON tree_nodes (is_main) WHERE is_main = TRUE;

      CREATE INDEX tree_nodes_placeholder_idx
         ON tree_nodes USING hash (placeholder);

      CREATE INDEX users_reason_of_ban_idx
        ON users
        USING btree
        (reason_of_ban)
        WHERE reason_of_ban IS NULL OR length(reason_of_ban::text) = 0;

      ALTER TABLE users ADD CONSTRAINT users_websites_fk FOREIGN KEY (website_id) REFERENCES websites (id)
         ON UPDATE NO ACTION ON DELETE NO ACTION;
      CREATE INDEX fki_users_websites_fk ON users(website_id);

      CREATE INDEX index_resources_on_id ON resources(id);
      CREATE INDEX gshilin_index_properties_on_id ON properties(id);
    my_code
    execute sql
  end

  def self.down
  end
end
