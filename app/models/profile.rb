# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document

  has_many :simulations, :dependent => :destroy
  has_many :features
  has_and_belongs_to_many :schedulers
  belongs_to :simulator
  belongs_to :run_time_configuration
  embeds_many :profile_entries
  field :proto_string
  after_create :create_profile_entries
  validates_presence_of :simulator

  after_save :set_run_time_configuration

  def set_run_time_configuration
    if run_time_configuration == nil
      self.update_attribute(:run_time_configuration_id, simulator.run_time_configurations.first.id)
    end
  end

  def create_profile_entries
    proto = proto_string.split(", ")
    proto.uniq.each {|strategy| profile_entries.create(:name => "#{strategy}: #{proto.count(strategy)}")}
  end

  def name
    profile_entries.reduce(""){|str, pe| str + pe.name + ", "}[0..-3]
  end

  def scheduled_count
    simulations.reduce(0){|sum, sim| sum + sim.size}.to_f + profile_entries.first.samples.count
  end

  def payoff_to_strategy(strategy)
    profile_entries.where(:name => strategy).first.samples.avg(:payoff)
  end

  def contains_strategy?(strategy)
    profile_entries.where(:name => strategy).count > 0
  end

end
