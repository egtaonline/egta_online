class ObservationProcessor
  def initialize(location="#{Rails.root}/tmp/data/")
    @location = location
  end

  def process_files(simulation, files)
    profile = simulation.profile
    validated = ObservationValidator.new.validate_all(profile, @location, files)
    if validated == []
      simulation.fail "No valid payoff files were found."
    else
      validated.each do |json|
        profile.observations.create!(json)
      end
      profile.update_symmetry_group_payoffs
      simulation.finish!
    end
  end
end