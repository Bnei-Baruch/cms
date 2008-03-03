class AuthenticationModel
  attr_reader :ac_type
  def initialize(access_type = 0)
      @ac_type = access_type
  end
  
   NODE_AC_TYPES = {
    #  Displayed        stored in db
    0 => "Forbidden",
    1 => "Read",
    2 => "Edit",
    3 => "Administer"
  }
  
  def to_s
    NODE_AC_TYPES[ac_type]
  end
  
  def current_user
    session[:user_id]
  end
end
