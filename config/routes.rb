ActionController::Routing::Routes.draw do |map|


  # map.resources :login, :member => {:login => :get, :logout => :get}

  # Tests
  map.resources :tests

  # Root access
  map.namespace(:admin) do |admin|
    #admin.connect '', :controller => 'resources'
    admin.resources :resources
    admin.resources :tree_nodes, :member => {:tree_node_ac_rights => :get}, :collection => { :ext => :get, :ext_old => :get }
    admin.resources :lists #, :collection => { :update_resource_type_properties => :get }
    admin.resources :websites, :collection => { :set_website => :get }
    admin.resources :properties
    admin.resources :resource_types, :member => {:associations_list => :get, :associations_update => :put}
    admin.resources :attachments
    admin.resources :users
    admin.resources :groups
    admin.resources :tree_node_ac_rights
    admin.resources :login, :collection => {:login => :get, :logout => :get}
    admin.resources :url_migrations, :collection => {:import => :get, :export => :get, :merge => :get, :cleanup => :get,  :error => :get}
  end	

  # Path to the site
  map.tm ':prefix/:id' , :controller => 'sites/templates' , :action => 'template'                                         
  map.js ':prefix/js/:id' , :controller => 'sites/javascripts' , :action => 'javascript'
  map.css 'stylesheets/:website_id/:css_id.css',
              :controller => 'sites/templates', 
              :action => 'stylesheet'
  map.image 'images/:image_id/:image_name.:format',
              :controller => 'Attachments',
              :action => 'get_image'
                

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route: map.connect 'products/:id', :controller => 'catalog', :action
  # => 'view' Keep in mind you can assign values other than :controller and :action

  # Sample of named route: map.purchase 'products/:id/purchase', :controller => 'catalog',
  # :action => 'purchase' This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' -- just remember to delete
  # public/index.html. map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension instead of a file named
  # 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'

end
