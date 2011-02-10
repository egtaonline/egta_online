# This model class represents features that have effects on game's outcome and
# hence need consideration

class Feature
  include Mongoid::Document

  field :name
  field :expected_value, :type => Float
  embeds_many :feature_samples

  embedded_in :game

  validates_presence_of :name
  validates_uniqueness_of :name

  def sample_count
    feature_samples.size
  end

  # Average value of feature value from samples available
  def sample_avg
    feature_samples.avg(:value)
  end
end
