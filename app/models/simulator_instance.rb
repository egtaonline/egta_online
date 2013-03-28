class SimulatorInstance
  include Mongoid::Document

  field :translation_table, type: Hash, default: {}
  field :counter, type: Integer, default: 0
  field :configuration, type: Hash, default: {}

  belongs_to :simulator
  has_many :schedulers, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :profiles, dependent: :destroy do
    def with_role_and_strategy(role, strategy)
      where(assignment: Regexp.new("#{role}:( \\d+ \\w+,)* \\d+ #{strategy}(,|;|\\z)"))
    end
  end

  validates_presence_of :simulator_id
  validates_uniqueness_of :configuration, scope: :simulator_id

  def get_storage_key(value)
    key = self.translation_table[value]
    if !key
      self.inc(:counter, 1)
      key = self.counter
      self.translation_table[value] = key
      self.save!
    end
    return key
  end
end