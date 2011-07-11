# Each Profile instance represents a single possible Strategy set for a Game.

class SymmetricProfile < Profile
  def yaml_rep
    strategy_array
  end

  def size
    profile_entries.reduce(0) {|sum, pe| sum + pe.name.split(": ")[1].to_i}
  end

  def strategy_array
    ret_array = Array.new
    profile_entries.each{|pe| pe.name.split(": ")[1].to_i.times{ret_array << pe.name.split(": ")[0]}}
    ret_array.sort
  end

  def create_profile_entries
    proto = proto_string.split(", ")
    proto.uniq.each {|strategy| profile_entries.create(:name => "#{strategy}: #{proto.count(strategy)}")}
  end

  def payoff_to_strategy(strategy)
    profile_entries.where(:name => /^#{strategy}/).first.samples.avg(:payoff)
  end

  def contains_strategy?(strategy)
    profile_entries.where(:name => /^#{strategy}/).count > 0
  end
end
