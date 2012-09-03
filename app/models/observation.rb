class Observation
  include Mongoid::Document

  embedded_in :profiles
  embeds_many :symmetry_groups, as: :role_strategy_partitionable
  field :features, type: Hash, default: {}

  accepts_nested_attributes_for :symmetry_groups
end