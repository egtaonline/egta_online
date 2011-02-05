class Player
  include Mongoid::Document
  field :strategy
  embeds_many :payoffs
  embeds_many :adjusted_payoffs
  embedded_in :profile, :inverse_of => :players

end