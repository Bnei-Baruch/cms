require 'lib/general_addons'
require 'lib/excel_exporter'

$config_manager = Configuration::ConfigurationManager.new
ActionView::Base.process_view_paths("#{RAILS_ROOT}/app/sites")
$files_location = Array.new
