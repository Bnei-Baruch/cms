class FixDuplicateTreeNodePermalinks < ActiveRecord::Migration
  def self.up
    sql = <<-my_code
    delete from tree_node_ac_rights where tree_node_id in (
        select 
          t.id 
        from 
          tree_nodes t join (
            select 
              permalink, 
              count(*) as c 
            from 
              tree_nodes 
            where 
              permalink is not null 
            group by 
              permalink
      ) a on t.permalink = a.permalink join resources r on (t.resource_id = r.id) where c > 1 and r.status = 'DELETED' order by a.permalink
    );

    delete from 
      tree_nodes 
    where 
      id in (
        select 
          t.id 
        from 
          tree_nodes t join (
            select 
              permalink, 
              count(*) as c 
            from 
              tree_nodes 
            where 
              permalink is not null 
            group by 
              permalink
      ) a on t.permalink = a.permalink join resources r on (t.resource_id = r.id) where c > 1 and r.status = 'DELETED' order by a.permalink
    );

    delete from tree_node_ac_rights where tree_node_id in (
        select 
          t.id 
        from 
          tree_nodes t join (
            select 
              permalink, 
              count(*) as c 
            from 
              tree_nodes 
            where 
              permalink is not null 
            group by 
              permalink
      ) a on t.permalink = a.permalink join resources r on (t.resource_id = r.id) where c > 1 and r.status = 'DRAFT' order by a.permalink
    );

    delete from 
      tree_nodes 
    where 
      id in (
        select 
          t.id 
        from 
          tree_nodes t join (
            select 
              permalink, 
              count(*) as c 
            from 
              tree_nodes 
            where 
              permalink is not null 
            group by 
              permalink
      ) a on t.permalink = a.permalink join resources r on (t.resource_id = r.id) where c > 1 and r.status = 'DRAFT' order by a.permalink
    );


    update tree_nodes set permalink = permalink || '-dublicate' where id in (3350, 24322, 23637);

    ALTER TABLE ONLY tree_nodes
        ADD CONSTRAINT tree_nodes_permalink_key UNIQUE (permalink);
    my_code
    execute sql

  end

  def self.down
  end
end
