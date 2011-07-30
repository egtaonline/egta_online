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
  validates_presence_of :simulator, :name, :size
  has_and_belongs_to_many :profiles, :default => []

  def ensure_profiles
    SymmetricProfile.where(:simulator_id => simulator.id, :parameter_hash => parameter_hash).sampled.each do |prof|
      if prof.game_ids.include?(self.id) == false
        check = true
        prof.strategy_array.uniq.each {|s| check = (strategy_array.include?(s) ? check : false)}
        if check
          self.profiles << prof
          prof.save!
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