require 'profile_statistics_updater'
require 'spec_helper'

describe ProfileStatisticsUpdater do
  describe 'update' do
    let!(:profile){ Fabricate(:profile) }

    it 'updates the statistics on the profile and its symmetry groups' do
      profile_id = profile.id
      jsons = [{ features: {}, symmetry_groups: profile.symmetry_groups.collect do |symmetry_group|
               {
                 role: symmetry_group.role, strategy: symmetry_group.strategy, count: symmetry_group.count, players: (1..symmetry_group.count).collect do |player|
                   { payoff: 100, features: {} }
                 end
               }
               end }]
      ProfileStatisticsUpdater.update(profile, jsons)
      profile = Profile.where(_id: profile_id).without(:observations).first
      profile.symmetry_groups.first.payoff.should == 100
      profile.sample_count.should == 1
      jsons = [{ features: {}, symmetry_groups: profile.symmetry_groups.collect do |symmetry_group|
               {
                 role: symmetry_group.role, strategy: symmetry_group.strategy, count: symmetry_group.count, players: (1..symmetry_group.count).collect do |player|
                   { payoff: 200, features: {} }
                 end
               }
               end }]
      ProfileStatisticsUpdater.update(profile, jsons)
      profile = Profile.where(_id: profile_id).without(:observations).first
      profile.symmetry_groups.first.payoff.should == 150.0
      profile.symmetry_groups.first.payoff_sd.should == 50.0
      profile.sample_count.should == 2
    end

    # it 'scales reasonably' do
    #   symmetry_group = profile.symmetry_groups.first
    #   symmetry_group.set(:count, 60)
    #   profile.reload
    #   profile_id = profile.id
    #   payoffs = []
    #   500.times do
    #     jsons = (1..5).collect do
    #               { "features" => {}, "symmetry_groups" => profile.symmetry_groups.collect do |symmetry_group|
    #                 {
    #                 "role" => symmetry_group.role, "strategy" => symmetry_group.strategy, "count" => symmetry_group.count, "players" => (1..symmetry_group.count).collect do |player|
    #                   payoff = rand
    #                   payoffs << payoff
    #                   { "payoff" => payoff, "features" => {} }
    #                 end
    #                 }
    #                end }
    #             end
    #     t1 = Time.now
    #     ProfileStatisticsUpdater.update(profile, jsons)
    #     puts Time.now-t1
    #     profile = Profile.where(_id: profile_id).without(:observations).first
    #   end
    #   profile.symmetry_groups.first.payoff.should == ArrayMath.average(payoffs)
    # end
  end
end