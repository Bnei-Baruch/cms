require 'lib/general_addons'

$config_manager = Configuration::ConfigurationManager.new
ActionView::Base.process_view_paths("#{RAILS_ROOT}/app/sites")

