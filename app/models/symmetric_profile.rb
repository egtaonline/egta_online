# Each Profile instance represents a single possible Strategy set for a Game.

class SymmetricProfile < Profile
  def yaml_rep
    strategy_array
  end
  
  def strategy_array
    ret_array = Array.new
    profile_entries.each{|pe| self[pe.name].times{ret_array << pe.name}}
    ret_array.sort
  end

  def name
    return_string = strategy_array.uniq.reduce("") {|string, strategy| string + strategy + ": #{self[strategy]}, "}
    return_string[0..-3]
  end

  def payoff_to_strategy(strategy)
    profile_entries.where(:name => strategy).first.samples.avg(:payoff)
  end

  def contains_strategy?(strategy)
    profile_entries.where(:name => strategy).count > 0
  end
end
