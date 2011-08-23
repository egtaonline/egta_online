class Scheduler
  include Mongoid::Document

  has_many :simulations, :inverse_of => :scheduler, :dependent => :destroy
  scope :active, where(active: true).excludes(simulator_id: nil)
  field :name
  field :active, :type => Boolean, :default => false
  field :process_memory, :type => Integer
  field :time_per_sample, :type => Integer
  field :samples_per_simulation, :type => Integer
  field :max_samples, :type => Integer
  field :parameter_hash, :type => Hash, :default => {}
  has_and_belongs_to_many :profiles
  belongs_to :simulator

  validates_uniqueness_of :name
  validates_presence_of :process_memory, :name, :time_per_sample
  validates_numericality_of :process_memory, :time_per_sample, :only_integer => true
  validates_numericality_of :samples_per_simulation, :max_samples, :only_integer=>true, :greater_than=>0
  
  def check_schedulability
    profile_ids.each {|p| Resque.enqueue(ProfileScheduler, self.id, p)}
  end

end