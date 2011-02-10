class AdjustmentCoefficientRecord
  include Mongoid::Document
  references_one :game
  embedded_in :simulator
  field :feature_hash, :type => Hash

  def calculate_coefficients(features)
    feature_hash = Hash.new

  end
end