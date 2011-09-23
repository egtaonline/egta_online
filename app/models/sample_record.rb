class SampleRecord
  include Mongoid::Document
  belongs_to :profile
  field :payoffs, type: Hash
  field :features, type: Hash
  validates_uniqueness_of :payoffs
  validates_presence_of :payoffs
end