class SampleRecord
  include Mongoid::Document
  embedded_in :profile
  field :payoffs, type: Hash, default: {}
  field :features, type: Hash, default: {}
  validates_presence_of :payoffs
end