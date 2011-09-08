class Sample
  include Mongoid::Document
  embedded_in :profile_entry
  field :payoff, :type => Float
  alias_attribute :value, :payoff

  validates_presence_of :payoff
  validates_numericality_of :payoff
end