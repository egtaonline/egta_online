class Scheduler
  include Mongoid::Document

  has_many :simulations, :inverse_of => :scheduler, :dependent => :destroy
  scope :active, where(active: true).excludes(simulator_id: nil)
  field :name
  field :active, :type => Boolean, :default => false
  field :process_memory, :type => Integer
  field :time_per_sample, :type => Integer
  field :samples_per_simulation, :type => Integer
  field :parameter_hash, :type => Hash, :default => {}
  field :nodes, :type => Integer, :default => 1
  field :simulator_fullname
  
  before_save(:on => :create){self.simulator_fullname = self.simulator.fullname}
  
  has_and_belongs_to_many :profiles, :inverse_of => nil do
    def with_role_and_strategy(role, strategy)
      where(:name => Regexp.new("#{role}:( \\d+ \\w+,)* \\d+ #{strategy}(,|;|\\z)"))
    end
  end
  
  belongs_to :simulator
  validates_uniqueness_of :name
  validates_presence_of :process_memory, :name, :time_per_sample, :samples_per_simulation, :nodes
  validates_numericality_of :process_memory, :time_per_sample, :nodes, :only_integer => true
  validates_numericality_of :samples_per_simulation, :only_integer=>true, :greater_than=>0
end