class ObservationProcessor
  def initialize(location="#{Rails.root}/tmp/data/")
    @location = location
  end

  def process_files(simulation, files)
    profile = Profile.where(_id: simulation.profile_id).without(:observations).first
    validated = ObservationValidator.new.validate_all(profile, @location, files)
    if validated == []
      simulation.fail "No valid payoff files were found."
    else
      ProfileStatisticsUpdater.update(profile, validated)
      simulation.finish
    end
  end
end