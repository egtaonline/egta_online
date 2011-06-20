class Account
  include Mongoid::Document

  field :username
  validates_presence_of :username

  validate :login
  field :encrypted_password

  def login
    begin
      Net::SSH.start(Yetting.host, username, :password => self.password, :timeout => 2)
    rescue
      errors.add(:username, "can't login to host")
    end
  end

  def password=(pass)
    if pass == "" || pass == nil
      errors.add(:password, "can't be empty")
    else
      self.update_attributes(:encrypted_password => pass.encrypt(:symmetric, :password => SECRET_KEY))
    end
  end

  def password
    if self.encrypted_password == nil
      ''
    else
      self.encrypted_password.decrypt(:symmetric, :password => SECRET_KEY)
    end
  end
end