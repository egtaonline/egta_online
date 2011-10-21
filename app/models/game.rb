class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include RoleManipulator

  field :name
  field :size, type: Integer
  embeds_many :roles
  field :parameter_hash, type: Hash, default: {}

  belongs_to :simulator, :index => true
  index :parameter_hash, background: true
  validates_presence_of :simulator, :name, :size
  field :profile_ids, :type => Array, :default => []
  after_create :find_profiles

  def add_strategy_by_name(role, strategy)
    role_i = roles.find_or_create_by(name: role)
    role_i.strategy_array << strategy
    role_i.save!
  end
  
  def delete_strategy_by_name(role, strategy)
    role_i = roles.where(name: role).first
    role_i.strategy_array.delete(strategy)
    role_i.save!
  end

  def strategy_regex
    Regexp.new("^"+roles.collect{|r| "#{r.name}: (#{r.strategy_array.sort.join('(, )?)*(')}(, )?)*"}.join("; ")+"$")
  end

  def find_profiles
    Resque.enqueue(ProfileGatherer, id)
  end
end