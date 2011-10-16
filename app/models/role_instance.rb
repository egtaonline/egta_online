class RoleInstance
  include Mongoid::Document
  embedded_in :profile
  field :name
  embeds_many :strategy_instances
  validates_uniqueness_of :name
end