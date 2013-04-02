class Simulation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Sequence

  belongs_to :profile, inverse_of: :simulations
  belongs_to :scheduler, inverse_of: :simulations
  delegate :nodes, to: :scheduler, prefix: true
  delegate :simulator_fullname, to: :scheduler

  field :size, type: Integer
  field :state
  field :job_id
  field :error_message, default: ''
  field :profile_assignment
  field :_id, type: Integer
  field :flux, type: Boolean, default: false
  sequence :_id
  index({ state: 1 })

  attr_readonly :profile_assignment, :size

  def self.simulation_limit
    [Backend.configuration.queue_quantity, Backend.configuration.queue_max-Simulation.active.count].min
  end

  scope :pending, where(state: 'pending')
  scope :queued, where(state: 'queued')
  scope :running, where(state: 'running')
  scope :stale, where(:state.in=>['queued', 'complete', 'failed']).and(:updated_at.lt => (Time.current-300000))
  scope :active, where(:state.in=>['queued','running'])
  scope :recently_finished, where(:state.in=>['complete', 'failed'], :updated_at.gt => (Time.current-86400))
  scope :scheduled, where(:state.in=>['pending','queued','running'])
  scope :queueable, pending.order_by([[:created_at, :asc]]).limit(simulation_limit)
  validates_inclusion_of :state, in: ['pending', 'queued', 'running', 'failed', 'complete']
  validates_presence_of :profile
  validates_numericality_of :size, only_integer: true, greater_than: 0

  before_save(on: :create){ self.profile_assignment = self.profile.assignment }
  before_destroy :cleanup

  def cleanup
    LocalSimulationCleanup.perform_async(id)
    BackendSimulationCleanup.perform_async(id)
  end

  def start
    self.update_attributes(state: 'running') if self.state == 'queued'
  end

  def finish
    self.update_attributes(state: 'complete')
    requeue
  end

  def queue_as(jid)
    self.update_attributes(job_id: jid, state: 'queued')
  end

  def fail(message)
    self.update_attributes(error_message: message, state: 'failed')
    requeue
  end

  def requeue
    self.profile.try_scheduling
  end
end