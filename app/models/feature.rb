class Feature
  include Mongoid::Document
  embedded_in :game
  field :name
  field :expected_value, :type => Float
  validates_presence_of :name
  validates_uniqueness_of :name
end