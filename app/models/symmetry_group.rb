class SymmetryGroup
  include Mongoid::Document
  
  embedded_in :profile
  embeds_many :players
  
  field :count, type: Integer
  field :role
  field :strategy
  
  validates :count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :role, presence: true
  validates :strategy, presence: true, uniqueness: { scope: :role }
end