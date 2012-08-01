class FeaturesObservation
  include Mongoid::Document
  
  embedded_in :profile
  
  field :features
  field :observation_id
  
  validates_presence_of :features, :observation_id
  
  before_validation(on: :create){ self.observation_id ||= self.profile.sample_count + 1 }
end