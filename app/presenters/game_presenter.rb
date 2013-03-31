class GamePresenter < JsonPresenter
  def initialize(game)
    @game = game
  end

  def to_json(options={})
    case options[:granularity]
    when "structure"
      structure
    when "full"
      full
    when "observations"
      observations
    else
      summary
    end
  end

  def structure
    json_base + json_end
  end

  def summary
    json_start +
    @game.profiles.select(sample_count: 1, 'symmetry_groups.role' => 1, 'symmetry_groups.strategy' => 1,
                          'symmetry_groups.count' => 1, 'symmetry_groups.payoff' => 1, 'symmetry_groups.payoff_sd' => 1).to_json +
    json_end
  end

  def observations
    json_start +
    @game.profiles.select('observations.features' => 1, 'observations.symmetry_groups.role' => 1,
                          'observations.symmetry_groups.strategy' => 1, 'observations.symmetry_groups.count' => 1,
                          'observations.symmetry_groups.payoff' => 1, 'observations.symmetry_groups.payoff_sd' => 1).to_json +
    json_end
  end

  def full
    json_start +
    @game.profiles.select('observations.features' => 1, 'observations.symmetry_groups.role' => 1,
                          'observations.symmetry_groups.strategy' => 1, 'observations.symmetry_groups.count' => 1,
                          'observations.symmetry_groups.players.payoff' => 1, 'observations.symmetry_groups.players.features' => 1).to_json +
    json_end
  end

  private

  def json_start
    json_base + ",\"profiles\":"
  end

  def json_base
    "{\"_id\":\"#{@game.id}\",\"name\":\"#{@game.name}\",\"simulator_fullname\":\"#{@game.simulator_fullname}\"," <<
    "\"configuration\":#{@game.simulator_instance.configuration.to_json}," <<
    "\"roles\":[#{@game.roles.collect{ |role| "{\"name\":\"#{role.name}\",\"strategies\":#{ role.strategies },\"count\":#{role.count}}" }.join(",") }]"
  end
end