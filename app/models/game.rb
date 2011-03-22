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
  field :size, :type => Integer
  validates_numericality_of :size, :integer_only => true

  referenced_in :simulator
  embeds_many :control_variates, :inverse_of => :game
  embeds_many :strategies
  embeds_many :profiles, :inverse_of => :game
  references_many :game_schedulers, :dependent => :destroy, :autosave => true
  embeds_many :features
  references_many :simulations, :dependent => :destroy

  def setup_parameters(simulator)
    self.parameters = Array.new
    YAML.load(simulator.parameters)["web parameters"].each_pair {|x, y| self[x] = y; self.parameters << x}
  end

  def calculate_cv_features(params, add=true)
    feature = features.find(params[:feature_id])
    if add
      params[:feature_names] << feature.name
    else
      params[:feature_names].delete("#{feature.name}")
    end
    params[:feature_names].collect{|s| [s, features.where(:name => s).first.id]}
  end

  def add_strategy_from_name(name)
    self.strategies.create(:name => name)
    simulator.strategies << name
    Stalker.enqueue 'update_profiles', :game => self.id
  end

  # Add Strategy to a Game
  def add_strategy(strategy)
    unless strategies.any? {|s| s == strategy}
      self.strategies << strategy
      self.save!
      ensure_profiles
    end
  end

  # Remove Strategy from a Game
  def remove_strategy(strategy)
    if strategies.any? {|s| s == strategy}
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
        profiles.create(:strategy_array => p_strategies)
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
end
