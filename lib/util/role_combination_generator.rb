class RoleCombinationGenerator
  def self.combinations(name, strategies, count)
    strategies.repeated_combination(count).collect{ |c| [name].concat(c) }
  end
end