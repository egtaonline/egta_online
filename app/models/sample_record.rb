class SampleRecord
  include Mongoid::Document
  belongs_to :profile
  field :payoffs, type: Hash
  field :features, type: Hash
end