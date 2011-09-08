# A symmetric game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class SymmetricGameScheduler < GameScheduler

  def ensure_profiles
    Resque.enqueue(SymmetricProfileAssociater, id)
  end
end
