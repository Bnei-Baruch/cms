require 'digest/sha1'
class User < ActiveRecord::Base
  validates_presence_of     :username
  validates_uniqueness_of   :username
  
  attr_accessor :user_password_confirmation
  validates_confirmation_of :user_password

  def validate
    errors.add_to_base("Missing password") if password.blank?
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
        if user.banned_reson != nil && user.banned_reson !=''
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
