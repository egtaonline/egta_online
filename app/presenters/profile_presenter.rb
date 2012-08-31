class ProfilePresenter
  def initialize(profile)
    @query = Profile.collection.find(_id: Moped::BSON::ObjectId(profile.id))
  end

  def to_json(options={})
    case options[:granularity]
    when "full"
      full
    when "observations"
      observations
    else
      summary
    end
  end

  def summary
    @query.select(sample_count: 1, 'symmetry_groups.role' => 1, 'symmetry_groups.strategy' => 1,
                          'symmetry_groups.count' => 1, 'symmetry_groups.payoff' => 1, 'symmetry_groups.payoff_sd' => 1).to_json
  end

  def observations
    @query.select('observations.features' => 1, 'observations.symmetry_groups.role' => 1,
                          'observations.symmetry_groups.strategy' => 1, 'observations.symmetry_groups.count' => 1,
                          'observations.symmetry_groups.payoff' => 1, 'observations.symmetry_groups.payoff_sd' => 1).to_json
  end

  def full
    @query.select('observations.features' => 1, 'observations.symmetry_groups.role' => 1,
                          'observations.symmetry_groups.strategy' => 1, 'observations.symmetry_groups.count' => 1,
                          'observations.symmetry_groups.players.payoff' => 1, 'observations.symmetry_groups.players.features' => 1).to_json
  end
end