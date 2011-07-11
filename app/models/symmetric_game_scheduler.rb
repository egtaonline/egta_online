# A symmetric game scheduler automaticallly creates Simulation jobs for a given Game
# instance

class SymmetricGameScheduler < GameScheduler

  def ensure_profiles
    strategy_array.repeated_combination(size).each do |prototype|
      prototype.sort!
      profile = SymmetricProfile.find_or_create_by(simulator_id: simulator.id, proto_string: prototype.join(", "), parameter_hash: parameter_hash)
      unless self.profiles.include?(profile)
        self.profiles << profile
        profile.save!
        simulation = profile.simulations.create!(
          :size => samples_per_simulation,
          :state => 'pending',
          :flux => (simulations.where(:flux => true, :state => 'queued').count < FLUX_CORES))
        simulations << simulation
        simulation.save!
      end
    end
  end

end
