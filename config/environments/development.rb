# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
# config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

#ZZZ TURN-THE-FOLLOWING-LINES-ON to enable cacheing in development mode
## and also in action_controller.rb
#ZZZ TURN-THE-FOLLOWING-LINES-ON config.action_controller.perform_caching             = true
#ZZZ TURN-THE-FOLLOWING-LINES-ON config.cache_store = :file_store, "tmp/cache/"



config.action_view.debug_rjs                         = true
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

#ZZZ Rails 2.2.2
config.dependency_loading = false

# Specify gems that this application depends on.
# They can then be installed with "rake gems:install" on new installations.
# You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
# config.gem "bj"
# config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
# config.gem "sqlite3-ruby", :lib => "sqlite3"
# config.gem "aws-s3", :lib => "aws/s3"

#config.action_view.warn_cache_misses = true