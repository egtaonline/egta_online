# This class represents simulations run by the testbed. It uses AASM (Act-As-State-Machine) gem to
# make a transition between different states.

class Simulation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Sequence

  belongs_to :account, :inverse_of => :simulations
  belongs_to :profile, :inverse_of => :simulations
  belongs_to :scheduler

  field :size, :type => Integer
  field :state
  field :job_id
  field :error_message
  field :flux, :type => Boolean
  field :created_at

  field :number, :type=>Integer
  sequence :number
  key :number

  scope :pending, where(:state=>'pending')
  scope :queued, where(:state=>'queued')
  scope :running, where(:state=>'running')
  scope :complete, where(:state=>'complete')
  scope :failed, where(:state=>'failed')
  scope :active, where(:state.in=>['queued','running'])
  scope :scheduled, where(:state.in=>['pending','queued','running'])

  validates_presence_of :state, :on => :create, :message => "can't be blank"
  validates_numericality_of :size, :only_integer=>true, :greater_than=>0

  state_machine :state, :initial => :pending do
    state :pending
    state :queued
    state :running
    state :complete
    state :failed

    after_transition :on => :failure do |simulation, transition|
      simulation.scheduler.reschedule(simulation)
    end

    event :queue do
      transition :pending => :queued
    end

    event :failure do
      transition [:pending, :queued, :running] => :failed
    end

    event :start do
      transition :queued => :running
    end

    event :finish do
      transition [:pending, :queued, :running, :failed] => :complete
    end

  end
end