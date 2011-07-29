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

  def add_profiles_from_strategy(strategy)
    SymmetricProfile.where(simulator_id: simulator.id, parameter_hash: parameter_hash).each do |prof|
      if prof.contains_strategy?(strategy) && prof.profile_entries.first.samples.count > 0
        self.profiles << prof
        prof.save!
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