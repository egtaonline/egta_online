class SampleRecord
  include Mongoid::Document
  embedded_in :profile
  field :payoffs, type: Hash
  field :features, type: Hash
  validates_presence_of :payoffs
  #after_create {profile.update_avgs_and_stds(self)}
end