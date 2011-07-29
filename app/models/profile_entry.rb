class ProfileEntry
  include Mongoid::Document

  embedded_in :profile
  embeds_many :samples

  field :name

  validates_presence_of :name

  def std_dev
    mean = samples.avg(:payoff)
    Math.sqrt(samples.reduce(0){|sum, u| sum + (u.payoff - mean) ** 2 } / (samples.length.to_f-1.0) )
  end

end