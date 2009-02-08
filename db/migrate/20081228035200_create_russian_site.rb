class CreateRussianSite < ActiveRecord::Migration
  def self.up
    migration_login
    
    # Hey! Draw me a website !
    rst = ResourceType.find(:first, :conditions => {:hrid => 'website'})
    
    #Explicit find of website fields
    prt1 = Property.find(:first, :conditions => {:resource_type_id => rst.id, :hrid => 'title'})
    prt2 = Property.find(:first, :conditions => {:resource_type_id => rst.id, :hrid => 'description'})
    prt3 = Property.find(:first, :conditions => {:resource_type_id => rst.id, :hrid => 'site_name'})
    prt4 = Property.find(:first, :conditions => {:resource_type_id => rst.id, :hrid => 'prefix'})
    prt5 = Property.find(:first, :conditions => {:resource_type_id => rst.id, :hrid => 'domain'})
    
    params = {
      :resource =>
        {
        :status => "PUBLISHED",
        :tree_node =>
          { 
          :permalink => "rusmain",
          :is_main => "true",
          :parent_id =>"0",
          :has_url => "true"
        },
     
        :resource_type_id => rst.id, 
   
        :my_properties =>
          [
          {:property_type => "RpString",
            :property_id => prt1.id, 
            :value => "russiansite",
            :remove =>""}, 
          {:property_type => "RpPlaintext",
            :property_id => prt2.id,
            :value => "russiansite",
            :remove =>""}, 
          {:property_type => "RpString",
            :property_id => prt3.id, 
            :value => "russiansite",
            :remove =>""}, 
          {:property_type => "RpString",
            :property_id => prt4.id, 
            :value =>"russiansite",
            :remove =>""},
          { :property_type => "RpString",
            :property_id => prt5.id, 
            :value =>"russiansite",
            :remove =>""}
        ]},
      
      :action => "create",
      :controller => "admin/resources"}
     
    
    rs_resource = Resource.new(params[:resource])
    raise 'Failed to create resource' unless rs_resource
    rs_resource.save!
    
    puts 'Resource, Tree node and properties created'
    
    website = {
      :name =>"Russian",
      :prefix =>"ruskab",
      :use_homepage_without_prefix => false,
      :domain =>"http://russian.localhost",
      :hrid =>"rusmain",
      :entry_point_id => rs_resource.id
    }
    
    rs_website = Website.new(website)
    raise 'Failed to create website' unless rs_website
    rs_website.save!

  end

  def self.down
    migration_login
    
    web_node = TreeNode.find(:first, :conditions => {:permalink => 'rusmain'})
    rs_id = web_node.resource_id
    web_node.delete
    puts 'Website deleted - OK'

    rtp = ResourceType.find(:first, :conditions => ['hrid = ?', 'website'])
    raise 'Failed to find rtp' unless rtp
    
    web_resource = Resource.find(:first, :conditions => {:resource_type_id => rtp.id, :id => rs_id})
    raise 'Failed to find web_resource' unless web_resource
    
    web_site = Website.find(:first, :conditions => {:prefix => 'ruskab', :hrid => 'rusmain'})
    raise 'Failed to find web_site' unless web_site
    
    prt = ResourceProperty.find(:all, :conditions => {:resource_id => rs_id})
    raise 'Failed to find properties for this specific resource' unless prt
    
    prt.each{|p|
      p.delete
      puts 'Property deleted - OK'
    } 
    
    web_resource.delete
    puts 'Resource deleted - OK'
    
    web_site.delete
    puts 'Website deleted - OK'
    
  end
end
