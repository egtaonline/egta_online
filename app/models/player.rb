class Player
  include Mongoid::Document
  embedded_in :profile, :inverse_of => :players
  
  field :strategy
  embeds_many :payoffs
  
  validates_presence_of :strategy, :on => :create, :message => "can't be blank"
end