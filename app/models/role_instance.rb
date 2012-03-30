class RoleInstance
  include Mongoid::Document
  embedded_in :profile
  field :name
  embeds_many :strategy_instances
  validates_uniqueness_of :name

  def strategy_count(strategy_name)
    strategy = strategy_instances.where(:name => strategy_name).first
    strategy == nil ? 0 : strategy.count
  end
end