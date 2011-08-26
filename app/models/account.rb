# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  has_many :simulations, :inverse_of => :account
  field :username
  validates_presence_of :username
  validate :login
  field :active, :type => Boolean, :default => false
  scope :active, where(active: true)

  after_create {Resque.enqueue(AccountAdder, id)}

  def login
    begin
      Net::SSH.start(Yetting.host, username, :timeout => 2)
    rescue
      errors.add(:username, "can't login to host")
    end
  end
end
