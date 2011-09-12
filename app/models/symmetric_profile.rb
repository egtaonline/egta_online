# Each Profile instance represents a single possible Strategy set for a Game.

class SymmetricProfile < Profile
  def yaml_rep
    strategy_array
  end

  def strategy_array
    proto_string.split(", ")
  end
  
  def contains_strategy?(strategy_name)
    proto_string.split(", ").include?(strategy_name)
  end
end
