class FeatureObservation
  include Mongoid::Document
  
  embedded_in :profile
  
  field :name
  field :observation
  field :observation_id
  
  validates_presence_of :name, :observation, :observation_id
  
  before_validation(on: :create){ self.observation_id = self.profile.sample_count + 1 }
end