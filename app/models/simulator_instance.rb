class SimulatorInstance
  include Mongoid::Document

  field :translation_table, type: Hash, default: {"payoff" => "p", "observation_symmetry_groups" => "sg",
                                                  "features" => "f", "payoff_sd" => "sd", "players" => "n"}
  field :counter, type: Integer, default: 0
  field :configuration, type: Hash, default: {}

  attr_readonly :configuration, :simulator_id

  belongs_to :simulator
  has_many :schedulers, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :profiles, dependent: :destroy

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