class Profile
  include Mongoid::Document

  embeds_many :symmetry_groups, as: :role_strategy_partitionable
  embeds_many :observations

  has_many :simulations, dependent: :destroy
  belongs_to :simulator

  field :size, type: Integer
  field :assignment, type: String
  field :sample_count, type: Integer, default: 0
  field :configuration, type: Hash, default: {}

  index ({ simulator_id: 1, configuration: 1, size: 1, sample_count: 1 })
  index ({ sample_count: 1 })
  index ({ assignment: 1 })
  index ({ 'observations.u_at' => 1 })
  validates_presence_of :simulator
  validates_format_of :assignment, with: /\A(\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+; )*\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+\z/
  validates_uniqueness_of :assignment, scope: [:simulator_id, :configuration]
  delegate :fullname, to: :simulator, prefix: true

  has_and_belongs_to_many :schedulers, index: true, inverse_of: nil do
    def with_max_samples
      active.max{ |x, y| x.required_samples(@base) <=> y.required_samples(@base) }
    end
  end

  scope :with_scheduler, ->(scheduler){ where(scheduler_ids: scheduler.id).without(:observations) }
  scope :with_role, ->(role){ elem_match(symmetry_groups: { role: role }) }
  scope :with_role_and_strategy, ->(role, strategy){ elem_match(symmetry_groups: { role: role, strategy: strategy }) }

  def strategies_for(role_name)
    symmetry_groups.where(role: role_name).collect{ |s| s.strategy }.uniq
  end

  def try_scheduling
    ProfileScheduler.perform_in(5.minutes, id)
  end

  def scheduled?
    simulations.scheduled.count > 0
  end

  def update_sample_count
    set(:sample_count, self.observations.count)
  end

  def payoffs_for(symmetry_group)
    observations.collect { |o| o.find_symmetry_group(symmetry_group.role, symmetry_group.strategy).payoffs }.flatten
  end
end