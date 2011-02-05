# This class represents simulations run by the testbed. It uses AASM (Act-As-State-Machine) gem to
# make a transition between different states.

class Simulation
  include Mongoid::Document
  include AASM

  field :size, :type => Integer
  field :state
  field :job_id
  field :error_message
  field :flux, :type => Boolean
  field :pbs_generator_id

  referenced_in :account
  embedded_in :profile
  embeds_many :samples

  scope :pending, where(:state=>'pending')
  scope :queued, where(:state=>'queued')
  scope :running, where(:state=>'running')
  scope :complete, where(:state=>'complete')
  scope :failed, where(:state=>'failed')
  scope :active, where(:state=>['queued','running'])
  scope :scheduled, where(:state=>['pending','queued','running'])

  validates_numericality_of :size, :only_integer=>true, :greater_than=>0

  aasm_column :state
  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :queued
  aasm_state :running
  aasm_state :complete
  aasm_state :failed

  aasm_event :queue do
    transitions :to => :queued, :from => [:pending]
  end

  aasm_event :fail do
    transitions :to => :failed, :from => [:pending, :queued, :running]
  end

  aasm_event :start do
    transitions :to => :running, :from => [:queued]
  end

  aasm_event :finish do
    transitions :to => :complete, :from => [:pending, :queued, :running, :failed]
  end

end
