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