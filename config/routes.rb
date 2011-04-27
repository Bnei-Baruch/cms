ActionController::Routing::Routes.draw do |map|

  # Tests
  map.resources :tests

  # Root access
  map.namespace(:admin) do |admin|
    #admin.connect '', :controller => 'resources'
    admin.resources :resources
    admin.resources :tree_nodes, :has_many => :tree_node_permissions,
      :member => {:tree_node_delete => :post, :update_state => :post },
      :collection => { :ext => :get, :ext_old => :get, :reset_order => :post }
    admin.resources :lists #, :collection => { :update_resource_type_properties => :get }
    admin.resources :websites, :collection => { :set_website => :get }
    admin.resources :properties
    admin.resources :resource_types, :member => {:associations_list => :get, :associations_update => :put}
    admin.resources :attachments
    admin.resources :users
    admin.resources :groups
    admin.resources :comments
    admin.resources :tree_node_ac_rights
    admin.resources :login, :collection => {:login => :get, :logout => :get}
    admin.resources :url_migrations, :collection => {:import => :get, :export => :get, :merge => :get, :cleanup => :get}
    admin.resources :courses, :collection => {:excel => :get}
  end	

  # REST API for fetching cms data
  map.connect '/api/first_page_article.:format', :controller => 'sites/api' , :action => 'get_first_page_article', :conditions => { :method => :get }
  map.connect '/api/categories.:format', :controller => 'sites/api' , :action => 'get_categories', :conditions => { :method => :get }
  map.connect '/api/article.:format', :controller => 'sites/api' , :action => 'get_article', :conditions => { :method => :get }
  map.connect '/api/articles.:format', :controller => 'sites/api' , :action => 'get_category_articles', :conditions => { :method => :get }
  map.connect '/api/article_comment.:format', :controller => 'sites/api' , :action => 'add_comment_to_article', :conditions => { :method => :post }
  map.connect '/api/article_comment.:format', :controller => 'sites/api' , :action => 'get_article_comment', :conditions => { :method => :get }
  map.connect '/api/article_comments.:format', :controller => 'sites/api' , :action => 'get_article_comments', :conditions => { :method => :get }
  map.connect '/api', :controller  => 'sites/api', :action => 'documentation'
  
  # shorturl controller : allow to make a link to a treenode based on tree node id
  # instead of permanlink (espacially useful for hebrew links)
  map.tm ':prefix/short/:id', :controller => 'sites/shorturl', :action => 'shorturl'
  
  # Email controller : initially build for 'send to your friend' function
  # with a though about the future - 
  # :id is the tree node id
  map.tm ':prefix/mail/:id/' , :controller => 'email' , :action => 'send_node'
 
  # Template controller - it is the main content controller for 90% of the site
  # :id is the permalink stuff (right, it is not consistent... so what ?!)
  map.connect '/feed.:format', :controller => 'sites/templates', :action => 'template'
  map.connect ':prefix/feed.:format' , :controller => 'sites/templates' , :action => 'template'
  map.connect ':prefix/:permalink/feed.:format' , :controller => 'sites/templates' , :action => 'template'
  map.tm ':prefix/:permalink' , :controller => 'sites/templates' , :action => 'template'

  
  # Mmm, I guess this one is for website homepage that do not make use of
  # prefix for the homepage - but not sure - should ask Rami
  # (anyway, he should have comment it on the firt place)
  
  map.connect '/', :controller => 'sites/templates', :action => 'template'
                                           
  map.js ':prefix/js/:id' , :controller => 'sites/javascripts' , :action => 'javascript'
  map.css 'stylesheets/:prefix/:css_id.css',
              :controller => 'sites/templates', 
              :action => 'stylesheet'
  map.css 'stylesheets/:css_id.css',
              :controller => 'sites/templates', 
              :action => 'stylesheet'
  map.image 'images/attachments/:image_id/:image_name.:format',
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
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'

  # We have two cases: 1) When the site's main page doesn't have prefix 2) When it has a prefix
  map.connect ':prefix/sitemap.xml', :controller => 'sites/templates', :action => 'sitemap' 
  map.connect '/sitemap.xml', :controller => 'sites/templates', :action => 'sitemap' 
  
  

  #this line is in conflict with the map.tm up there - need to be solved
  #map.tm ':prefix' , :controller => 'sites/templates' , :action => 'template'

  # Used mainly for URL migrations (Checking Legacy URLs)
  map.connect '/*path', :controller => 'sites/templates', :action => 'template'
  
end
