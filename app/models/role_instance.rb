class RoleInstance
  include Mongoid::Document
  embedded_in :profile
  field :name
  embeds_many :strategy_instances
  validates_uniqueness_of :name

  def strategy_count(strategy_name)
    profile.strategy_count(self.name, strategy_name)
  end

  def action_count_map
    ac_map = {}
    strategy_instances.all.each do |s|
      s = ::Strategy.where(:name => s.name).first
      key = {:number => s.number, :name => s.name}
      ac_map[key] = strategy_count(s.name)
    end
    ac_map
  end
end