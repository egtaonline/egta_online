class Scheduler
  include Mongoid::Document

  has_many :simulations, :inverse_of => :scheduler, :dependent => :destroy
  scope :active, where(active: true).excludes(simulator_id: nil)
  field :name
  field :active, :type => Boolean, :default => false
  field :process_memory, :type => Integer
  field :time_per_sample, :type => Integer
  field :samples_per_simulation, :type => Integer
  field :nodes, :type => Integer, :default => 1
  field :simulator_fullname
  field :configuration, type: Hash, default: {}
  field :size, type: Integer
  field :default_samples, type: Integer
  embeds_many :roles, as: :role_owner, order: :name.asc
  validates_numericality_of :default_samples, integer_only: true
  
  scope :scheduling_profile, ->(profile_id) { active.where(profile_ids: profile_id) }
  
  accepts_nested_attributes_for :configuration
  
  before_save(:on => :create){self.simulator_fullname = self.simulator.fullname}
  
  has_and_belongs_to_many :profiles, :inverse_of => nil do
    def with_role_and_strategy(role, strategy)
      where(assignment: Regexp.new("#{role}:( \\d+ \\w+,)* \\d+ #{strategy}(,|;|\\z)"))
    end
  end
  
  belongs_to :simulator
  validates_uniqueness_of :name
  validates_presence_of :process_memory, :name, :time_per_sample, :samples_per_simulation, :nodes, :configuration, :size
  validates_numericality_of :process_memory, :time_per_sample, :nodes, :only_integer => true
  validates_numericality_of :samples_per_simulation, only_integer: true, greater_than: 0
  
  def create_game_to_match
    game = Game.create!(name: name, size: size, simulator_id: simulator_id, configuration: configuration)
    add_strategies_to_game(game)
    game
  end
  
  def schedule_profile(profile)
    samples_to_schedule = [samples_per_simulation, required_samples(profile.id)-profile.sample_count].min
    self.simulations.create!(size: samples_to_schedule, state: 'pending', profile_id: profile.id) if samples_to_schedule > 0
  end
end