module HierarchicalReduction

  private

  def arrays_to_cross
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      combinations = role.strategies.repeated_combination(role.count).to_a
      if first_ar == nil
        first_ar = combinations.collect{|c| [role.name].concat(c) }
      else
        all_other_ars << combinations.collect{|c| [role.name].concat(c) }
      end
    end
    return first_ar, all_other_ars
  end

  def multiply(array)
    ar = []
    array.each {|a| agents_per_player.times{ar << a}}
    ar
  end

  def format_role(role)
    strats = multiply(role.drop(1))
    "#{role[0]}: " + strats.uniq.collect{|s| "#{strats.count(s)} #{s}" }.join(", ")
  end

  def add_strategies_to_game(game)
    roles.each do |r|
      game.roles.create!(name: r.name, count: r.count*agents_per_player)
      r.strategies.each{ |s| game.add_strategy(r.name, s) }
    end
  end
end