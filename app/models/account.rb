# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  field :username
  field :active, :type => Boolean, :default => false
  
  has_many :simulations
  
  # Allows us to get all active Accounts with Account.active
  scope :active, where(:active => true)
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validate :login, :group_permission, :on => :create

  # Ensure that the password is not stored in the database, because public key login has been setup
  after_validation(:on => :create) do
    self["password"] = nil
    self["skip"] = true
  end
  
  # Ensure that the credentials provided are correct
  def login
    if self["skip"] != true
      begin
        Net::SSH.start(Yetting.host, username, password: password, timeout: 2) do |s|
          s.exec!("echo #{KEY} >> ~/.ssh/authorized_keys")
        end
      rescue
        errors.add(:username, "Cannot authenticate on nyx as \'#{self.username}\' with provided password.")
      end
    end
  end
  
  # Ensure that the user has the wellman group permission on the cluster
  def group_permission
    if errors[:username] == [] && self["skip"] != true
      begin
        groups = ""
        Net::SSH.start(Yetting.host, username) do |s|
          groups = s.exec!("groups")
        end
        errors.add(:username, "\'#{self.username}\' is not a member of wellman group.  Ask Mike to add you.") if groups.split(" ").include?("wellman") == false
      rescue
        errors.add(:username, "Could not connect to nyx, try again later.")
      end
    end
  end
end
