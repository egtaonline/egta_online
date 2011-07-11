class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :name
  field :description

  has_many :profiles
end