# This model class has adjusted payoff values for players in a Game. It is identical to Payoff, but also has one-to-one
# relationship with its corresponding Payoff.

class AdjustedPayoff
  include Mongoid::Document
  belongs_to :profile
  belongs_to :payoff
  belongs_to :sample
  belongs_to :player

  validates_presence_of :profile_id
  validates_presence_of :sample_id
  validates_presence_of :player_id
  validates_numericality_of :payoff

  before_save :check_parent_profile

  # Check if a given profile has a parent Profile. If so, it gets linked with
  # the parent profile
  def check_parent_profile
    if self.profile.parent_profile
      self.profile = self.profile.parent_profile
    end
  end
end
