# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  has_many :simulations, :inverse_of => :account
  field :username
  index :username, unique: true
  validates_presence_of :username
  validates_uniqueness_of :username
  validate :login
  field :active, :type => Boolean, :default => false
  scope :active, where(active: true)

  def login
    if self["skip"] != true
      begin
        Net::SSH.start(Yetting.host, username, :timeout => 2) do |ssh|
          groups = ssh.exec!("groups")
          errors.add(:username, "is not a member of wellman group.  Ask Mike to add you.") if groups.split(" ").include?("wellman") == false 
        end
      rescue
        errors.add(:username, "can't login to host")
      end
    end
  end
end
