class FeatureObservation
  include Mongoid::Document
  
  embedded_in :profile
  
  field :name
  field :observation
  field :observation_id
  
  validates_presence_of :name, :observation, :observation_id
end