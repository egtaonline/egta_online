# This model class represents features that have effects on game's outcome and
# hence need consideration

class Feature
  include Mongoid::Document

  field :expected_value, :type => Float
  belongs_to :profile
  embeds_many :samples

  field :name

  validates_presence_of :name

end
