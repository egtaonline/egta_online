# This model class contains sample data collected from Simulation for each Feature

class FeatureSample
  include Mongoid::Document

  field :value
  embedded_in :feature
  embedded_in :sample

  validates_numericality_of :value
end
