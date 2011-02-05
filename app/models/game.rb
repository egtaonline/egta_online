# This model class represents games and corresponding Profiles are automatically
# generated given possible strategies

class Game
  include Mongoid::Document
  field :description
  field :parameters, :type => Array
  validates_presence_of :parameters
  field :name
  validates_presence_of :name
  validates_uniqueness_of :name
  key :name
  field :size, :type => Integer
  validates_numericality_of :size, :integer_only => true

  references_one :simulator
  embeds_many :strategies
  embeds_many :profiles
  embeds_many :game_schedulers
  embeds_many :deviation_schedulers
  embeds_many :profile_schedulers
  embeds_many :features
  embeds_many :simulations

  # Add Strategy to a Game
  def add_strategy(strategy)
    unless strategies.any? {|s| s == strategy}
      self.strategies << strategy
      Stalker.enqueue 'update_profiles', :game => self.id
    end
  end

  # Remove Strategy from a Game
  def remove_strategy(strategy)
    if strategies.any? {|s| s == strategy}
      prune_profile(strategy)
      strategy.destroy
    end
  end

#   # This should find (or generate) all profiles that are used by Game, given the current set of strategies available.
  def ensure_profiles

    p = Array.new(self.size, 0)
    while p != nil
      p_strategies = p.collect {|i| strategies[i].name}
      p_strategies.sort!
      profile = profiles.detect {|x| x.strategy_array == p_strategies}
      unless profile
        profile = Profile.new
        profiles << profile
        profile.save
        profile.strategy_array = p_strategies
      end

      p = next_profile(p, strategies.length, self.size)
    end
  end

  def next_profile(array, n_strategies, profile_size)
    if array.nil? || array.empty?
      nil
    elsif array.last == (n_strategies - 1)
      next_profile(array[0..-2], n_strategies, profile_size)
    else
      a = array.clone
      a[-1] += 1
      a.concat(Array.new(profile_size - a.length, a[-1]))
      a
    end
  end

  def prune_profile(strategy)
    p = profiles.select{|x| x.contains_strategy?(strategy.name) == false}
    to_delete = profiles - p
    while to_delete.length > 0
      to_delete[0].destroy
      to_delete.delete_at(0)
    end
  end

  def full_id
    "#{simulator.id}:#{self.id}"
  end
end
