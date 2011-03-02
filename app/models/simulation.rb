# This class represents simulations run by the testbed. It uses AASM (Act-As-State-Machine) gem to
# make a transition between different states.

class Simulation
  include Mongoid::Document
  include Mongoid::Timestamps
  referenced_in :account, :inverse_of => :simulations
  embedded_in :profile, :inverse_of => :simulations

  field :size, :type => Integer
  field :state
  field :job_id
  field :error_message
  field :flux, :type => Boolean
  field :created_at
  field :serial_id, :type => Integer
  embeds_many :samples

  scope :pending, where(:state=>'pending')
  scope :queued, where(:state=>'queued')
  scope :running, where(:state=>'running')
  scope :complete, where(:state=>'complete')
  scope :failed, where(:state=>'failed')
  scope :active, where(:state.in=>['queued','running'])
  scope :scheduled, where(:state.in=>['pending','queued','running'])

  validates_presence_of :state, :flux, :serial_id, :on => :create, :message => "can't be blank"
  validates_numericality_of :size, :only_integer=>true, :greater_than=>0
  before_destroy :kill_payoffs

  def kill_payoffs
    if profile != nil
      samples.all.each {|sample| sample.kill_payoffs}
    end
  end
  
  state_machine :state, :initial => :pending do
    state :pending
    state :queued
    state :running
    state :complete
    state :failed

    event :queue do
      transition :pending => :queued
    end

    event :fail do
      transition [:pending, :queued, :running] => :failed
    end

    event :start do
      transition :queued => :running
    end

    event :finish do
      transition [:pending, :queued, :running, :failed] => :complete
    end

  end

  before_create :setup_id

  def setup_id
    self.serial_id = SimCount.first.counter
    SimCount.first.update_attributes(:counter => SimCount.first.counter+1)
  end
end