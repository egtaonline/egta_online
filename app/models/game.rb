#symmetric only for now
class Game
  include StrategyManipulation
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  has_many :analysis_items, :as => :analyzable

  field :name
  field :size, :type => Integer
  field :strategy_array, :type => Array, :default => []
  field :parameter_hash, :type => Hash, :default => {}

  belongs_to :simulator
  validates_presence_of :simulator
  has_and_belongs_to_many :profiles

  def ensure_profiles
    strategy_array.repeated_combination(size).each do |prototype|
      prototype.sort!
      profile = SymmetricProfile.find_or_create_by(simulator_id: simulator.id, proto_string: prototype.join(", "), parameter_hash: parameter_hash)
      unless self.profiles.include?(profile)
        self.profiles << profile
        profile.save!
      end
    end
  end

  def completion_percent
    profiles.reduce(0) {|sum, profile| sum + (profile.profile_entries.first.samples.count == 0 ? 0 : 1)}*100/profiles.count
  end
end