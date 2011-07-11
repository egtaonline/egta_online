class AsymmetricGameScheduler < GameScheduler

  def ensure_profiles
    strategy_array.repeated_permutation(size).each do |prototype|
      profile = AsymmetricProfile.find_or_create_by(:simulator_id => simulator.id,
                                          :parameter_hash => parameter_hash,
                                          :proto_string => prototype.join(", "))
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