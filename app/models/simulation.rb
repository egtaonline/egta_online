# This class represents simulations run by the testbed. It uses AASM (Act-As-State-Machine) gem to
# make a transition between different states.

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
  field :created_at
  field :profile_assignment
  field :_id, type: Integer
  sequence :_id
  index({ state: 1 })

  scope :pending, where(state: 'pending')
  scope :queued, where(state: 'queued')
  scope :running, where(state: 'running')
  scope :complete, where(state: 'complete')
  scope :failed, where(state: 'failed')
  scope :stale, where(:state.in=>['queued', 'complete', 'failed']).and(:updated_at.lt => (Time.current-300000))
  scope :active, where(:state.in=>['queued','running'])
  scope :finished, where(:state.in=>['complete', 'failed'])
  scope :recently_finished, where(:state.in=>['complete', 'failed'], :updated_at.gt => (Time.current-86400))
  scope :scheduled, where(:state.in=>['pending','queued','running'])
  scope :queueable, pending.order_by([[:created_at, :asc]]).limit(Backend.configuration.queue_quantity)
  validates_presence_of :state, on: :create, message: "can't be blank"
  validates_presence_of :profile
  validates_numericality_of :size, only_integer: true, greater_than: 0

  before_save(on: :create){ self.profile_assignment = self.profile.assignment }

  state_machine :state, initial: :pending do
    state :pending
    state :queued
    state :running
    state :complete
    state :failed

    after_transition on: [:failure, :finish], do: :requeue

    event :queue do
      transition [:queued, :pending] => :queued
    end

    event :failure do
      transition [:pending, :queued, :running] => :failed
    end

    event :start do
      transition [:queued, :running] => :running
    end

    event :finish do
      transition [:pending, :queued, :running, :failed] => :complete
    end
  end

  def queue_as(jid)
    self.job_id = jid
    self.state = 'queued'
    self.save
  end

  def fail(message)
    self.error_message = message
    self.state = 'failed'
    self.save
    requeue
  end

  def requeue
    self.profile.try_scheduling
  end
end