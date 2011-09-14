# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  has_many :analysis_items, :as => :analyzable

  has_many :simulations, :dependent => :destroy
  has_many :sample_records
  belongs_to :simulator, :index => true
  index ([[:parameter_hash, Mongo::DESCENDING], [:proto_string, Mongo::DESCENDING]]), unique: true, background: true
  embeds_many :profile_entries
  field :size, type: Integer
  field :proto_string
  field :parameter_hash, :type => Hash, :default => {}
  field :payoff_avgs, :type => Hash, :default => {}
  field :payoff_stds, :type => Hash, :default => {}
  field :feature_avgs, :type => Hash, :default => {}
  field :feature_stds, :type => Hash, :default => {}
  field :feature_expected_values, type: Hash, default: {}
  after_create :setup
  validates_presence_of :simulator, :proto_string
  validates_uniqueness_of :proto_string, :scope => [:simulator_id, :parameter_hash]

  def update_avgs_and_stds(sample_record)
    sample_record.payoffs.each do |key, value|
      if payoff_avgs[key] == nil
        payoff_avgs[key] = value
        payoff_stds[key] = [1, value, value**2, nil]
      else
        payoff_avgs[key] = (payoff_avgs[key]*(sample_records.count-1)+value)/sample_records.count
        s0 = payoff_stds[key][0]+1
        s1 = payoff_stds[key][1]+value
        s2 = payoff_stds[key][2]+value**2
        payoff_stds[key] = [s0, s1, s2, Math.sqrt((s0*s2-s1**2)/(s0*(s0-1)))]
      end
    end
    sample_record.features.each do |key, value|
      if feature_avgs[key] == nil
        feature_avgs[key] = value
        feature_stds[key] = [1, value, value**2, nil]
      else
        feature_avgs[key] = (feature_avgs[key]*(sample_records.count-1)+value)/sample_records.count
        s0 = feature_stds[key][0]+1
        s1 = feature_stds[key][1]+value
        s2 = feature_stds[key][2]+value**2
        feature_stds[key] = [s0, s1, s2, Math.sqrt((s0*s2-s1**2)/(s0*(s0-1)))]
      end
    end
    self.save!
  end

  def self.extract_strategies(profiles)
    profiles.reduce([]){|set, profile| set.concat profile.strategy_array.uniq }.uniq
  end

  def keys
    proto_string.split(", ").uniq
  end

  def name
    proto_string
  end

  def scheduled_count
    simulations.active.reduce(0){|sum, sim| sum + sim.size}.to_i + simulations.pending.reduce(0){|sum, sim| sum + sim.size}.to_i + sample_count
  end

  def sampled
    self.sample_count > 0
  end

  def sample_count
    sample_records.count
  end

  def setup
    find_games
  end

  def find_games
    Resque.enqueue(GameAssociater, id)
  end

  def try_scheduling
    Resque.enqueue(ProfileScheduler, id)
  end
end
