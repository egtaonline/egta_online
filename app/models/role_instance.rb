class RoleInstance
  include Mongoid::Document
  embedded_in :profile
  field :name
  field :payoff_avgs, type: Hash, default: {}
  field :payoff_stds, type: Hash, default: {}
  validates_uniqueness_of :name
end