object @object

attributes :role, :strategy

case @granularity
when "summary"
  attributes :count, :payoff, :payoff_sd
when "observation"
  attribute :count
  node :payoff do |symmetry_group|
    symmetry_group.payoff_for(@observation_id)
  end
  node :payoff_sd do |symmetry_group|
    symmetry_group.payoff_sd_for(@observation_id)
  end
when "full"
  node :players do |symmetry_group|
    symmetry_group.players.where(observation_id: @observation_id).collect { |player| partial "api/v3/profiles/player", object: player }
  end
end
  