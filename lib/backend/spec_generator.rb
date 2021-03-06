class SpecGenerator
  def self.generate(simulation, directory="#{Rails.root}/tmp/simulations")
    spec = {}
    profile = Profile.where(_id: simulation.profile_id).without(:observations).first
    spec["assignment"] = Hash.new{ |hash, key| hash[key] = [] }
    profile.symmetry_groups.each do |symmetry_group|
      symmetry_group.count.times{ spec["assignment"][symmetry_group.role] << symmetry_group.strategy }
    end
    spec["configuration"] = profile.configuration
    Oj.to_file("#{directory}/#{simulation.id}/simulation_spec.json", spec, indent: 2)
  end
end