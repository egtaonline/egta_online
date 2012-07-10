class SpecGenerator
  def self.generate(file, profile)
    spec = {}
    spec[:assignment] = Hash.new{ |hash, key| hash[key] = [] }
    profile.symmetry_groups.each do |symmetry_group|
      symmetry_group.count.times{ spec[:assignment][symmetry_group.role] << symmetry_group.strategy }
    end
    spec[:configuration] = profile.configuration
    Oj.to_file(file, spec, indent: 2)
  end
end