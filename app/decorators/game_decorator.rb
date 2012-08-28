class GameDecorator < Draper::Base
  decorates :game

  def summary
    json_start +
    model.profiles.select(sample_count: 1, 'symmetry_groups.role' => 1, 'symmetry_groups.strategy' => 1,
                          'symmetry_groups.count' => 1, 'symmetry_groups.payoff' => 1, 'symmetry_groups.payoff_sd' => 1).entries +
    json_end
  end

  def observations
    json_start +
    model.profiles.select('observations.features' => 1, 'observations.symmetry_groups.role' => 1,
                          'observations.symmetry_groups.strategy' => 1, 'observations.symmetry_groups.count' => 1,
                          'observations.symmetry_groups.payoff' => 1, 'observations.symmetry_groups.payoff_sd' => 1).entries +
    json_end
  end

  def full
    json_start +
    model.profiles.select('observations.features' => 1, 'observations.symmetry_groups.role' => 1,
                          'observations.symmetry_groups.strategy' => 1, 'observations.symmetry_groups.count' => 1,
                          'observations.symmetry_groups.players.payoff' => 1, 'observations.symmetry_groups.players.features' => 1).entries +
    json_end
  end

  private

  def json_start
    "{
       \"_id\": \"#{model.id}\",
       \"name\": \"#{model.name}\",
       \"simulator_fullname\": \"#{model.simulator_fullname}\",
       \"configuration\": #{model.configuration},
       \"roles\": #{model.roles.collect{ |role| "{ \"name\": \"#{role.name}\", \"strategies\": #{ role.strategies }, \"count\": #{role.count} }" }.join(", ") },
       \"profiles\": "
  end

  def json_end
    "\n}"
  end
end