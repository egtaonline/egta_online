class Player
  include Mongoid::Document
  field :strategy
  embeds_many :payoffs
  embedded_in :profile, :inverse_of => :players
end