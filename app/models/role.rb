class Role
  include Mongoid::Document
  field :name
  field :count, type: Integer
  field :strategy_array, type: Array, default: []
  alias :to_s :name
  embedded_in :simulator
  embedded_in :game
  embedded_in :scheduler
  validates_presence_of :name
end