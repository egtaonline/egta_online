class ProfileEntry
  include Mongoid::Document

  embedded_in :profile
  embeds_many :samples

  field :name

  validates_presence_of :name
end