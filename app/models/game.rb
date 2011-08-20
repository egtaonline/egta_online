#symmetric only for now
class Game
  include StrategyManipulation
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  has_many :analysis_items, :as => :analyzable

  field :name
  field :size, :type => Integer
  field :strategy_array, :type => Array, :default => []
  field :parameter_hash, :type => Hash, :default => {}

  belongs_to :simulator, :index => true
  index :parameter_hash, background: true
  validates_presence_of :simulator, :name, :size
  has_and_belongs_to_many :profiles
  after_create :find_profiles

  def strategy_regex
    Regexp.new("^(#{strategy_array.sort.join('(, )?)*(')}(, )?)*$")
  end

  def ensure_profiles
    true
  end

  def find_profiles
    Resque.enqueue(ProfileGatherer, id)
  end

  def completion_percent
    if strategy_array.size > 0
      profiles.select{|p| p.sampled == true}.count*100/((size+strategy_array.size-1).downto(1).inject(:*)/(size.downto(1).inject(:*)*([strategy_array.size-1, 1].max).downto(1).inject(:*)))
    else
      "N/A"
    end
  end
end