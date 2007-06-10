ActionController::Routing::Routes.draw do |map|
  map.resources :object_types, :languages
  map.resources :items, :member => {
      :labels => :get,
			:new_label => :get,
			:create_label => :post,
			:edit_label => :get,
			:update_label => :put,
			:destroy_label => :delete}

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
