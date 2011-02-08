# This model class contains sample data collected from Simulation for each Feature

class FeatureSample
  include Mongoid::Document
  field :feature_name
  field :value
  embedded_in :feature
  field :sample_id

  validates_numericality_of :value
end
