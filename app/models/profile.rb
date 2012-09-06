class Profile
  include Mongoid::Document

  embeds_many :symmetry_groups, as: :role_strategy_partitionable
  embeds_many :observations

  has_many :simulations, dependent: :destroy
  belongs_to :simulator

  field :size, type: Integer
  field :assignment, type: String
  field :sample_count, type: Integer, default: 0
  field :features, type: Hash, default: {}
  field :configuration, type: Hash, default: {}

  attr_accessible :assignment, :configuration

  index ({ simulator_id: 1, configuration: 1, size: 1, sample_count: 1 })

  validates_presence_of :simulator
  validates_format_of :assignment, with: /\A(\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+; )*\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+\z/
  validates_uniqueness_of :assignment, scope: [:simulator_id, :configuration]
  delegate :fullname, to: :simulator, prefix: true

  has_and_belongs_to_many :schedulers, index: true, inverse_of: nil do
    def with_max_samples
      active.max{ |x, y| x.required_samples(@base) <=> y.required_samples(@base) }
    end
  end

  scope :with_scheduler, ->(scheduler){ where(scheduler_ids: scheduler.id) }
  scope :with_role, ->(role){ elem_match(symmetry_groups: { role: role }) }
  scope :with_role_and_strategy, ->(role, strategy){ elem_match(symmetry_groups: { role: role, strategy: strategy }) }

  def strategies_for(role_name)
    symmetry_groups.where(role: role_name).collect{ |s| s.strategy }.uniq
  end

  def try_scheduling
    Resque.enqueue_in(5.minutes, ProfileScheduler, id)
  end

  def scheduled?
    simulations.scheduled.count > 0
  end

  def update_symmetry_group_payoffs
    self.sample_count = self.observations.count
    if self.sample_count > 0
      self.symmetry_groups.each do |symmetry_group|
        payoffs = observations.collect { |o| o.symmetry_groups.where(role: symmetry_group.role, strategy: symmetry_group.strategy).first.players.collect { |p| p.payoff } }.flatten
        symmetry_group.payoff = payoffs.reduce(:+)/payoffs.count
        symmetry_group.payoff_sd = Math.sqrt([payoffs.collect{ |p| p**2.0 }.reduce(:+)/payoffs.count-symmetry_group.payoff**2.0, 0].max)
        symmetry_group.save!
      end
      new_features = Hash.new { |hash, key| hash[key] = [] }
      observations.each do |observation|
        observation.features ||= {}
        observation.save
        observation.features.each do |name, value|
          new_features[name] << value
        end
      end
      new_features.each do |key, value|
        new_features[key] = value.reduce(:+)/value.size
      end
      self.features = new_features
      self.save!
    end
  end
end