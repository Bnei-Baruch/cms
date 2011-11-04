# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + '/../../config/environment') unless defined?(Rails)

class PageCache

  USER_ANONYMOUS = 2

  class << self;
    attr_accessor :homepage
    @@homepages = {}
    Website.find(:all).each {|site|
      @@homepages[site.domain] = site.entry_point_id
    }
  end
  
  def self.logged_in?(env)
    session = env['rack.session']
    Thread.current[:session] = session
    return session[:user_id] != USER_ANONYMOUS
  end
  
  def self.call(env)
    # Render page in case of a logged in user
    return [404, {'Content-Type' => 'text/html', 'X-Cascade' => 'pass'}, ['Logged in']] if logged_in?(env) || env['REQUEST_METHOD'] != 'GET'

    # Find out a slug and try to fetch its ID
    if env['PATH_INFO'] == '/' # Homepage
      node = @@homepages["http://#{env['SERVER_NAME']}"]
    else
      permalink = env['PATH_INFO'].split(/\//).last
      begin
        node  = TreeNode.find_by_permalink permalink
        node &&= node.id
      rescue
        node = nil
      end
    end

    # Unable to find node ID
    return [404, {'Content-Type' => 'text/html', 'X-Cascade' => 'pass'}, ['Not Found']] unless node
    
    content = false
    # If cache exists - read it
    Dir.glob("tmp/cache/tree_nodes/#{node}-*.cache"){|fname|
      File.open(fname, "r") { |file|
        content = file.read
      }
    }
    if content
      [200, {'Content-Type' => 'text/html'}, [content]]
    else
      [404, {'Content-Type' => 'text/html', 'X-Cascade' => 'pass'}, ['Cache not Found']]
    end
  end

end
