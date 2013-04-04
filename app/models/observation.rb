class Observation
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  embedded_in :profiles
  embeds_many :observation_symmetry_groups
  field :features, type: Hash, default: {}
end