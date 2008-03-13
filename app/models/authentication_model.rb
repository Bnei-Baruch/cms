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
  
  def can_edit?
    @ac_type == 2 || @ac_type == 3
  end
  
  def can_read?
    @ac_type == 1 || @ac_type == 2 || @ac_type == 3
  end
  
  def can_delete?
    @ac_type == 3
  end
  
  def can_administrate?
    @ac_type == 3
  end
  
  def to_s
    NODE_AC_TYPES[ac_type]
  end
  
  def self.get_ac_type_to_tree_node(tree_node_id)
    sql = ActiveRecord::Base.connection()
    if current_user.nil?
      return 0 #"Forbidden"
    end
    if current_user_is_admin?
      return 3 #"Administrating"
    end
    res = sql.execute("select get_max_user_permission(#{current_user},#{tree_node_id}) as value")
    answ = res.getvalue( 0, 0 )
    answ ||= 0
    return answ
  end
  
  def self.current_user
    $session[:user_id]
  end
  
  def self.current_user_is_admin?
    $session[:user_is_admin]==1
  end
end
