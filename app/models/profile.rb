# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  
  embeds_many :symmetry_groups
  embeds_many :feature_observations

  has_many :simulations, :dependent => :destroy
  belongs_to :simulator

  field :size
  field :assignment, type: Hash
  field :sample_count, type: Integer, default: 0
  field :configuration, type: Hash, default: {}
  
  attr_accessible :assignment, :configuration
  
  # TODO: find the right indexes
  # index ([[:simulator_id,  Mongo::ASCENDING], [:configuration_id, Mongo::ASCENDING], [:size, Mongo::ASCENDING], [:sample_count, Mongo::ASCENDING]])

  validates_presence_of :simulator
  validates_format_of :assignment, with: /\A(\w+:( \d+ \w+,)* \d+ \w+; )*\w+:( \d+ \w+,)* \d+ \w+\z/
  validates_uniqueness_of :assignment, scope: [:simulator_id, :configuration]
  delegate :fullname, :to => :simulator, :prefix => true

  after_create :find_games

  # 
  # def adjusted_sample_records
  #   self.sample_records.skip(10)
  # end
  
  def strategies_for(role_name)
    symmetry_groups.where(role: role_name).collect{ |s| s.strategy }.uniq
  end
  
  def find_games
    Resque.enqueue(GameAssociater, id)
  end

  def try_scheduling
    Resque.enqueue_in(5.minutes, ProfileScheduler, id)
  end

end