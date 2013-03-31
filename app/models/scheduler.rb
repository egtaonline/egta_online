class Scheduler
  include Mongoid::Document

  has_many :simulations, inverse_of: :scheduler, dependent: :destroy
  scope :active, where(active: true).excludes(simulator_id: nil)
  field :name
  field :active, type: Boolean, default: false
  field :process_memory, type: Integer
  field :time_per_sample, type: Integer
  field :samples_per_simulation, type: Integer
  field :nodes, type: Integer, default: 1
  field :simulator_fullname
  field :size, type: Integer
  field :default_samples, type: Integer
  embeds_many :roles, as: :role_owner, order: :name.asc

  validates_numericality_of :default_samples, integer_only: true

  before_save(on: :create){self.simulator_fullname = self.simulator_instance.simulator.fullname}

  belongs_to :simulator_instance
  validates_uniqueness_of :name
  validates_presence_of :process_memory, :name, :time_per_sample, :samples_per_simulation, :nodes, :size, :simulator_instance_id
  validates_numericality_of :process_memory, :time_per_sample, :nodes, only_integer: true
  validates_numericality_of :samples_per_simulation, only_integer: true, greater_than: 0

  def self.create_with_simulator_instance(params)
    if params
      simulator_id = params.delete(:simulator_id)
      configuration = params.delete(:configuration)
      params[:simulator_instance_id] = SimulatorInstance.find_or_create_by(simulator_id: simulator_id, configuration: configuration).id
    end
    create(params)
  end

  def update_with_simulator_instance(params)
    if params
      configuration = params.delete(:configuration)
      params[:simulator_instance_id] = SimulatorInstance.find_or_create_by(simulator_id: simulator_instance.simulator_id, configuration: configuration).id
    end
    self.update_attributes(params)
    self
  end

  def find_or_create_profile(assignment)
    profile = simulator_instance.profiles.find_or_create_by(assignment: assignment)
    if profile.valid?
      profile.add_to_set(:scheduler_ids, id)
      profile.try_scheduling
    end
  end

  def create_game_to_match
    game = Game.create!(name: name, size: size, simulator_instance_id: simulator_instance_id)
    add_strategies_to_game(game)
  end

  def schedule_profile(profile)
    self.simulations.create!(size: samples_to_schedule(profile), state: 'pending', profile_id: profile.id) if samples_to_schedule > 0
  end

  def samples_to_schedule(profile)
    [samples_per_simulation, required_samples(profile)-profile.sample_count].min
  end

  def profiles
    Profile.with_scheduler(self)
  end

  def remove_self_from_profiles(profiles_to_remove)
    profiles_to_remove.pull(:scheduler_ids, id)
  end
end