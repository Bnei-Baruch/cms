class Kabtv < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "kabtv_#{RAILS_ENV}".to_sym
end
