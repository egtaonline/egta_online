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
      if SymmetricProfile.where(simulator_id: simulator.id, proto_string: prototype.join(", "), parameter_hash: parameter_hash).count > 0 && SymmetricProfile.where(simulator_id: simulator.id, proto_string: prototype.join(", "), parameter_hash: parameter_hash).first.profile_entries.first.samples.count > 0
        profile = SymmetricProfile.where(simulator_id: simulator.id, proto_string: prototype.join(", "), parameter_hash: parameter_hash).first;
        unless self.profiles.include?(profile)
          self.profiles << profile
          profile.save!
        end
      end
    end
  end

  def completion_percent
    if strategy_array.size > 0
      profiles.size*100/((size+strategy_array.size-1).downto(1).inject(:*)/(size.downto(1).inject(:*)*(strategy_array.size-1).downto(1).inject(:*)))
    else
      "N/A"
    end
  end
end