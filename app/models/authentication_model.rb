class AuthenticationModel
  attr_reader :ac_type
  def initialize(access_type = 0)
      @ac_type = access_type
  end
  
   NODE_AC_TYPES = {
    #  Displayed        stored in db
    0 => "Forbidden",
    1 => "Reading",
    2 => "Editing",
    3 => "Administrating"
  }
  
  def to_s
    NODE_AC_TYPES[ac_type]
  end
  
  def self.get_ac_type_to_tree_node(tree_node_id)
    return 3
    sql = ActiveRecord::Base.connection()
    if current_user.nil?
      return 0
    end
    res = sql.execute("select get_max_user_permission(#{current_user},#{tree_node_id}) as value")
    return res.getvalue( 0, 0 )
  end
  
  def self.current_user
    $session[:user_id]
  end
end
