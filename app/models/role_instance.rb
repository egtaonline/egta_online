class RoleInstance
  include Mongoid::Document
  embedded_in :profile
  field :name
  embeds_many :strategy_instances
  validates_uniqueness_of :name

  def strategy_count(strategy_name)
    profile.strategy_count(self.name, strategy_name)
  end
end