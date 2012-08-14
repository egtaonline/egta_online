class Observation
  include Mongoid::Document
  
  embeds_many :symmetry_groups, as: :role_strategy_partitionable
  field :features, type: Hash
  
  accepts_nested_attributes_for :symmetry_groups
end