class RunTimeConfiguration
  include Mongoid::Document

  belongs_to :simulator
  has_many :schedulers
  has_many :profiles

  field :parameters, :type => Hash

  def name
    parameters.to_a.reduce(""){|str, entry| str + "#{entry[0]}: #{entry[1]}, "}[0..-3]
  end
end