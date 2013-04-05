class Observation
  include Mongoid::Document
  include Mongoid::Timestamps::Updated::Short

  embedded_in :profiles
  embeds_many :observation_symmetry_groups, store_as: :sg
  field :f, as: :features, type: Hash, default: {}
end