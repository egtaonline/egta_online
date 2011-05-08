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

  belongs_to :simulator
  embeds_many :control_variates, :inverse_of => :game
  embeds_many :adjustment_coefficient_records
  embeds_many :strategies
  embeds_many :profiles, :inverse_of => :game
  has_many :schedulers, :dependent => :destroy
  embeds_many :features
  has_many :simulations, :dependent => :destroy

  def setup_parameters(params)
    self.parameters = Array.new
    params.each_pair {|x, y| self[x] = y; self.parameters << x if self.parameters.include?(x) == false}
  end

  def remove_payoffs(profile_id, sample_id)
    profile = profiles.find(profile_id)
    profile.players.each do |player|
      player.payoffs.where(:sample_id => sample_id).each do |payoff|
        payoff.delete
      end
    end
  end

  def remove_feature_samples(sample_id)
    features.each{|feature| feature.feature_samples.where(:sample_id => sample_id).destroy_all}
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

  def synchronous_add_strategy_from_name(name)
    if strategies.where(:name => name).count == 0
      self.strategies.create!(:name => name)
      ensure_profiles
    end
  end

  def add_strategy_from_name(name)
    if strategies.where(:name => name).count == 0
      self.strategies.create!(:name => name)
      Stalker.enqueue 'update_profiles', :game => self.id
    end
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
  def remove_strategy(strategy_name)
    profiles.each {|profile| if profile.contains_strategy?(strategy_name); profile.destroy; end}
  end

#   # This should find (or generate) all profiles that are used by Game, given the current set of strategies available.
  def ensure_profiles

    p = Array.new(self.size, 0)
    while p != nil
      p_strategies = p.collect {|i| strategies[i].name}
      p_strategies.sort!
      profile = profiles.detect {|x| x.strategy_array == p_strategies}
      unless profile
        prof = profiles.create!
        p_strategies.each {|strategy| prof.players.create!(:strategy => strategy)}
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
