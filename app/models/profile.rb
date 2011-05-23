# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document

  belongs_to :game
  has_many :simulations, :dependent => :destroy
  has_many :features
  embeds_many :profile_entries

  def scheduled_count
    simulations.reduce(0){|sum, sim| sum + sim.size}.to_f + profile_entries.first.samples.count
  end

end
