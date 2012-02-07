# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  has_many :simulations
  field :username
  index :username, unique: true
  validates_presence_of :username
  validates_uniqueness_of :username
  validate :login, :group_permission
  field :active, :type => Boolean, :default => false
  scope :active, where(active: true)

  after_validation(:on => :create) do
    self["password"] = nil
    self["skip"] = true
  end
  
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
