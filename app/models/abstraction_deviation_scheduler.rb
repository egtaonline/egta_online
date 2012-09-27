class AbstractionDeviationScheduler < AbstractionScheduler
  include Deviations

  def reduced_game_with_devs
    profs = reduced_game
    reduced_game.each do |profile|
      profile.each do |role, strategy_hash|
        strategy_hash.each do |strategy, count|
          deviating_roles.where(name: role).first.strategies.each do |dev_strategy|
            dev_prof = profile.deep_copy
            if dev_prof[role][strategy] == 1
              dev_prof[role].delete(strategy)
            else
              dev_prof[role][strategy] -= 1
            end
            dev_prof[role][dev_strategy] ||= 0
            dev_prof[role][dev_strategy] += 1
            profs << dev_prof
          end
        end
      end
    end
    profs.uniq
  end
end