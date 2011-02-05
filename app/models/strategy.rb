# This model class represents available strategies for a Game

class Strategy
  include Mongoid::Document

  field :name
  field :description

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :game
  key :name
  embedded_in :game

end
