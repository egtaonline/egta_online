class ProfileEntry
  include Mongoid::Document

  embedded_in :profile
  embeds_many :samples
  after_save :check_samples
  field :name

  validates_presence_of :name

  def check_samples
    if profile.sampled == true && samples.count == 0
      profile.update_attribute(:sampled, false)
    elsif profile.sampled == false && samples.count != 0
      profile.update_attribute(:sampled, true)
    end
  end

  def std_dev
    mean = samples.avg(:payoff)
    Math.sqrt(samples.reduce(0){|sum, u| sum + (u.payoff - mean) ** 2 } / (samples.length.to_f-1.0) )
  end

end