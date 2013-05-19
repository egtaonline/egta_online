require 'spec_helper'

describe GamePresenter do
  let(:game){ Fabricate(:game, size: 4) }
  let(:profile){ Fabricate(:profile, simulator: game.simulator, configuration: game.configuration,
                                     assignment: 'Role1: 2 Strat1; Role2: 1 Strat2, 1 Strat3') }
  subject{ GamePresenter.new(game) }

  before do
    game.add_role('Role1', 2)
    game.add_strategy('Role1', 'Strat1')
    game.add_role('Role2', 2)
    game.add_strategy('Role2', 'Strat2')
    game.add_strategy('Role2', 'Strat3')
    ProfileStatisticsUpdater.update(profile, [{features: { feature1: 23, feature2: 25 },
                                 symmetry_groups: [
                                   { role: 'Role1', strategy: 'Strat1', count: 2, players: [
                                     { payoff: 10.0, features: { pfeature1: -11, pfeature2: 0.23 } },
                                     { payoff: 12.0, features: { pfeature1: -9, pfeature2: 0.43 } }
                                     ], payoff: 11.0, payoff_sd: 1.0 },
                                   { role: 'Role2', strategy: 'Strat2', count: 1, players: [
                                     { payoff: 10.0, features: { pfeature3: -11, pfeature4: 0.27 } }
                                     ], payoff: 10.0, payoff_sd: 0.0 },
                                   { role: 'Role2', strategy: 'Strat3', count: 1, players: [
                                     { payoff: 10.0, features: { pfeature3: -14, pfeature4: 0.47 } }
                                     ], payoff: 10.0, payoff_sd: 0.0 }
                                   ]}])
  end

  describe '#to_json' do
    context 'undefined granularity or summary granularity' do
      let(:response) do
<<HEREDOC
{"_id":"#{game.id}","name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.to_json},"roles":[{"name":"Role1","strategies":["Strat1"],"count":2},{"name":"Role2","strategies":["Strat2", "Strat3"],"count":2}],"profiles":[{"_id":"#{profile.id}","sample_count":1,"symmetry_groups":[{"count":2,"payoff":11.0,"payoff_sd":1.0,"role":"Role1","strategy":"Strat1"},{"count":1,"payoff":10.0,"payoff_sd":0.0,"role":"Role2","strategy":"Strat2"},{"count":1,"payoff":10.0,"payoff_sd":0.0,"role":"Role2","strategy":"Strat3"}]}]}
HEREDOC
      end

      it { subject.to_json.should eql(response) }
      it { subject.to_json(granularity: 'summary').should eql(response) }
    end

    context 'observation granularity' do
      let(:response) do
<<HEREDOC
{"_id":"#{game.id}","name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.to_json},"roles":[{"name":"Role1","strategies":["Strat1"],"count":2},{"name":"Role2","strategies":["Strat2", "Strat3"],"count":2}],"profiles":[{"_id":"#{profile.id}","observations":[{"features":{"feature1":23,"feature2":25},"symmetry_groups":[{"role":"Role1","strategy":"Strat1","count":2,"payoff":11.0,"payoff_sd":1.0},{"role":"Role2","strategy":"Strat2","count":1,"payoff":10.0,"payoff_sd":0.0},{"role":"Role2","strategy":"Strat3","count":1,"payoff":10.0,"payoff_sd":0.0}]}]}]}
HEREDOC
      end

      it { subject.to_json(granularity: 'observations').should eql(response) }
    end
    context 'full granularity' do
      let(:response) do
<<HEREDOC
{"_id":"#{game.id}","name":"#{game.name}","simulator_fullname":"#{game.simulator_fullname}","configuration":#{game.configuration.to_json},"roles":[{"name":"Role1","strategies":["Strat1"],"count":2},{"name":"Role2","strategies":["Strat2", "Strat3"],"count":2}],"profiles":[{"_id":"#{profile.id}","observations":[{"features":{"feature1":23,"feature2":25},"symmetry_groups":[{"role":"Role1","strategy":"Strat1","count":2,"players":[{"features":{"pfeature1":-11,"pfeature2":0.23},"payoff":10.0},{"features":{"pfeature1":-9,"pfeature2":0.43},"payoff":12.0}]},{"role":"Role2","strategy":"Strat2","count":1,"players":[{"features":{"pfeature3":-11,"pfeature4":0.27},"payoff":10.0}]},{"role":"Role2","strategy":"Strat3","count":1,"players":[{"features":{"pfeature3":-14,"pfeature4":0.47},"payoff":10.0}]}]}]}]}
HEREDOC
      end

      it { subject.to_json(granularity: 'full').should eql(response) }
    end
  end
end