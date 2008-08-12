class RecalculateTreeNodesPositions < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    create or replace function cms_recalculate_treenodes_order()
    returns integer AS
    $BODY$
    declare
    c refcursor;
    id1 integer;
    parent_id integer;
    i integer;
    old_parent_id integer;
    point integer;
    q varchar;
    placeholder varchar(255);
    old_placeholder varchar(255);
    begin
    -- iterate through results
    i := 1;
    old_parent_id := 0;
    old_placeholder = 'kavana';
    OPEN c FOR EXECUTE 'select tr.id, parent_id, placeholder from tree_nodes tr inner join resources rs ON tr.resource_id = rs.id where rs.status <> ''DELETED'' order by parent_id, placeholder, position, updated_at';
    loop
    fetch c into id1, parent_id, placeholder;
    exit when NOT FOUND;

    if (old_parent_id <> parent_id or old_placeholder <> placeholder) then
    i := 1;
    old_parent_id := parent_id;
    old_placeholder := placeholder;
    else
    i := i + 1;
    end if;

    update tree_nodes
    set position = i
    where id = id1;

    end loop;

    close c;

    return 1;
    end
    $BODY$
    language 'plpgsql' volatile;

    select cms_recalculate_treenodes_order();
    my_code
    execute sql
  end

  def self.down
  end
end
