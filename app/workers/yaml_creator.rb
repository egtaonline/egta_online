class YAMLCreator
  @queue = :nyx_actions

  def self.perform(simulation_id)
    simulation = Simulation.find(simulation_id) rescue nil
    if simulation != nil
      File.open( "#{Rails.root}/tmp/temp.yaml", 'w' ) do |out|
        YAML.dump(Profile.find(simulation.profile_id).yaml_rep, out)
        YAML.dump(numeralize(simulation.scheduler), out)
      end
    end
  end

  def numeralize(scheduler)
    p = Hash.new
    scheduler.parameter_hash.each_pair do |x, y|
      if is_a_number?(y)
        p[x] = y.to_f
      else
        p[x] = y
      end
    end
    p
  end

  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
end