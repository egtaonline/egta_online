class Player
  include Mongoid::Document
  
  embedded_in :symmetry_group
  
  field :payoff, type: Float
  field :observation_id, type: Integer
  field :features, type: Hash, default: {}
  
  # validates :payoff, presence: true, numericality: true
  # validates :observation_id, presence: true, numericality: { only_integer: true }
  # 
  # before_validation(on: :create){ self.observation_id ||= self.symmetry_group.profile.sample_count + 1 }
end