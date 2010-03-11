class LoadAllResourceProperties < ActiveRecord::Migration
  def self.up
    migration_login
    sum = 0
    Resource.find_in_batches() do |batch|
      sum += batch.size
      puts sum
      batch.each do |resource|
        next if resource == nil
        resource.get_empty_resource_properties.each{|rp| rp.save }
      end
    end
  end

  def self.down
  end
end
