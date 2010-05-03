# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class PageCache

  def self.logged_in?(env)
    session = env["rack.session"]
    Thread.current[:session] = session
    return session[:user_id] != 2 # 2 for Anonymous !!! ZZZ must be requested
  end
  
  def self.call(env)
    # Render page in case of a logged in user
    return [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Logged in"]] if logged_in?(env) || env['REQUEST_METHOD'] != 'GET'

    # Find out a slug and try to fetch its ID
    if env["PATH_INFO"] == '/' # Homepage
      node = 17
    else
      permalink = env["PATH_INFO"].split(/\//).last
      node  = TreeNode.find_by_permalink permalink
      node &&= node.id
    end

    # Unable to find node ID
    return [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]] unless node
    
    content = false
    # If cache exists - read it
    Dir.glob("tmp/cache/tree_nodes/#{node}-*.cache"){|fname|
      File.open(fname, "r") { |file|
        content = file.read
      }
    }
    if content
      [200, {"Content-Type" => "text/html"}, [content]]
    else
      [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Cache not Found"]]
    end
  end
end

module ActiveSupport
  module Cache
    # A cache store implementation which stores everything on the filesystem.
    class FileStore < Store
      def read(name, options = nil)
        super
        File.open(real_file_path(name), 'rb') { |f| f.read } rescue nil
      end

      def write(name, value, options = nil)
        super
        ensure_cache_path(File.dirname(real_file_path(name)))
        File.atomic_write(real_file_path(name), cache_path) { |f| f.write(value) }
        value
      rescue => e
        logger.error "Couldn't create cache directory: #{name} (#{e.message})" if logger
      end
    end
  end
end
