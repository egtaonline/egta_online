Fabricator(:profile) do
  after_create do |profile|
    profile.players << Fabricate.build(:player, :strategy => "BayesianPricing:noRA:0.0")
    profile.players << Fabricate.build(:player, :strategy => "AmbiguityAversePricing:noRA:0.0")
  end
end
