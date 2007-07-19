ActionController::Routing::Routes.draw do |map|
  map.resources :object_types, :collection => { :add_label_rule => :get }
  map.resources :languages
  map.resources :items, :collection => { :add_free_label => :get, :add_rule_label => :get }
  map.resources :items do |label|
    label.resources :item_labels
  end


  #  map.resources :item_labels, :controller => "item_labels",
  #                         :path_prefix => "items/:item_id",
  #                         :name_prefix => "item_"

  #This route should be before the labels nested resource route
  #becouse all generated combinations for labels
  #will be overwritten by the nested labels resource.
  #Otherwise it won't work.
  map.resources :labels do |label|
    label.resources :label_descs
  end

  map.resources :label_types do |label_types|
    label_types.resources :labels, :label_type_descs
  end

end
