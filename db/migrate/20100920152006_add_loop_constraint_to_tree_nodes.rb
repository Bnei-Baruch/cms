class AddLoopConstraintToTreeNodes < ActiveRecord::Migration
  def self.up
		sql = <<-my_code
		-- Create objects

		CREATE OR REPLACE FUNCTION cms_update_tree_nodes()
			RETURNS trigger AS
		$BODY$
						DECLARE
						l_i integer;
						BEGIN

						if NEW.parent_id is not null then
								select parent_id into l_i from tree_nodes where id = NEW.parent_id;
								if l_i = NEW.id or NEW.parent_id = NEW.id then
								RAISE EXCEPTION 'Loop tree node';
								end if;
						end if;
						RETURN NEW;
					 
						END;
				$BODY$
			LANGUAGE 'plpgsql' VOLATILE;

		CREATE TRIGGER cms_update_tree_nodes_trigger
			BEFORE INSERT OR UPDATE
			ON tree_nodes
			FOR EACH ROW
			EXECUTE PROCEDURE cms_update_tree_nodes();
    my_code
    execute sql

  end

  def self.down
		sql = <<-my_code
		-- Remove objects

		DROP TRIGGER cms_update_tree_nodes_trigger ON tree_nodes;

		DROP FUNCTION cms_update_tree_nodes();
    my_code
    execute sql
  end
end
