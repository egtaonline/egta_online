# A symmetric game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class SymmetricGameScheduler < GameScheduler

  def ensure_profiles
    strategy_array.repeated_combination(size).each do |prototype|
      proto_string = prototype.sort.join(", ")
      Resque.enqueue(SymmetricProfileAssociater, id, proto_string)
    end
  end

end
