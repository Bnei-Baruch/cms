require 'digest/sha1'
class User < ActiveRecord::Base
  validates_presence_of     :username
  validates_uniqueness_of   :username#, :case_sansitive =>true
  validates_length_of :username, :maximum => 20
  
  
  attr_accessor :user_password_confirmation
  validates_confirmation_of :user_password

  #validates_length_of :user_password, in => 6..20 
  #validates_length_of :password, :within => 6..20
  has_and_belongs_to_many :groups
  
  def validate
    errors.add_to_base("Missing password") if password.blank?
    if (user_password.length<4 || user_password.length>20) && !user_password.blank?
        errors.add_to_base("Password should has 6 - 20 characters")
    end
  end
  
  def user_password
    @user_password
  end
  
  def user_password=(pwd)
    @user_password = pwd
    return if pwd.blank?
    create_new_salt
    self.password = User.encrypted_password(self.user_password, self.salt)
  end
  
   def self.authenticate(username, user_password)
    user = self.find_by_username(username)
    if user
      expected_password = encrypted_password(user_password, user.salt)
      if user.password != expected_password
        user = nil
      else
        if user.reason_of_ban != nil && user.reason_of_ban !=''
          user = nil
        end
      end
    end
    user
  end
  
  private
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt  # 'wibble' makes it harder to guess
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
end
