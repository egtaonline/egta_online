require_relative 'reduction_creator'

class DprCreator < ReductionCreator
  def self.expand_assignment(assignment, roles)
    assignment.collect do |role_combination|
      role_name = role_combination[0]
      strategies = hasherize(role_combination.drop(1))
      strategies.collect do |strategy, count|
        roles.collect do |role|
          if role.name == role_name
            [role.name].concat(strategy_dehasherize(expand_for_target_strategy(strategy, strategies, role)))
          else
            combination = assignment.detect{ |rc| rc[0] == role.name }
            [role.name].concat(strategy_dehasherize(expand_role(hasherize(combination.drop(1)), role.count)))
          end
        end
      end
    end.flatten(1)
  end

  private

  def self.expand_for_target_strategy(strategy, strategies, role)
    other_players = strategies.dup
    other_players[strategy] -= 1
    new_strategies = expand_role(other_players, role.count-1)
    new_strategies[strategy] ||= 0
    new_strategies[strategy] += 1
    new_strategies
  end
end
#     reduced_profile[role.name].each do |strategy, count|
#       full_profile = {}
#       roles.each do |r|
#         if role.name == r.name
#           everyone_else = reduced_profile[r.name].deep_copy
#           everyone_else[strategy] -= 1
#           full_profile[r.name] = AbstractionScheduler.fill_role(everyone_else, r.count-1)
#           full_profile[r.name][strategy] ||= 0
#           full_profile[r.name][strategy] += 1
#         else
#           full_profile[r.name] = AbstractionScheduler.fill_role(reduced_profile[r.name], r.count)
#         end
#       end
#       prof_hashes << full_profile
#     end
# prof_hashes.uniq.collect{ |profile| dehasherize(profile) }