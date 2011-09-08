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
  field :profile_ids, :type => Array, :default => []
  belongs_to :simulator

  validates_uniqueness_of :name
  validates_presence_of :process_memory, :name, :time_per_sample
  validates_numericality_of :process_memory, :time_per_sample, :only_integer => true
  validates_numericality_of :samples_per_simulation, :max_samples, :only_integer=>true, :greater_than=>0
  around_save :check_changes
  
  def check_changes
    puts "I'm checking changes"
    pflag = false
    aflag = false
    if parameter_hash_changed?
      puts "found a change"
      self.profile_ids = []
      pflag = true
    end
    if (active_changed? and active_was == false) or max_samples_changed?
      puts "found a different change"
      aflag = true
    end
    yield
    if pflag
      ensure_profiles
    elsif aflag and self.profile_ids != nil
      profile_ids.each{|p| Resque.enqueue(ProfileScheduler, p)}
    end
  end
end