class VariableEstimator
  
  attr_accessor :control_variables
  
  #control_variables = {name: {expected_value: value}}
  def initialize(game, target_variable, control_variables, role_strategy_hash)
    @game, @target_variable, @control_variables = game, target_variable, control_variables
    @sd = 1.0/0.0
    @profiles = get_profiles(role_strategy_hash)
    1.upto(@control_variables.keys.size) do |i|
      @control_variables.keys.combination(i) do |combination|
        puts "testing #{combination}"
        calculate_coefficients(combination)
        observation_hash = apply_coefficients(combination)
        sd = get_sd(observation_hash)
        if sd < @sd
          puts "better"
          @sd = sd
          @observation_hash = observation_hash
        end
      end
    end
  end
  
  def calculate_coefficients(combination)
    observations = []
    feature_hash = Hash.new {|hash, key| hash[key] = []}
    @profiles.each do |profile|
      profile.sample_records.limit(10).collect do |sample_record|
        flag = true
        combination.each do |name|
          flag = false if sample_record.features[name] == nil
        end
        if flag
          combination.each do |name|
            feature_hash[name] << sample_record.features[name]
          end
          observations << sample_record.features[@target_variable]
        end
      end
    end
    if observations != []
      feature_hash.each{|key, value| feature_hash[key] = feature_hash[key].to_scale}
      ds = feature_hash.to_dataset
      ds['target'] = observations.to_scale
      lr = Statsample::Regression.multiple(ds, 'target')
      combination.each do |key|
        @control_variables[key]["coeff"] = lr.coeffs[key]
      end
    end
  end
  
  def apply_coefficients(combination)
    observation_hash = {}
    before = []
    after = []
    @profiles.each do |profile|
      observations = []
      profile.sample_records.each do |sample_record|
        mu = sample_record.features[@target_variable]
        puts "Nil mu" if mu == nil
        adjustments = combination.collect{|key| sample_record.features[key] == nil ? 0 : @control_variables[key]["coeff"]*(sample_record.features[key]-@control_variables[key]["expected_value"])}
        adjustments = adjustments.reduce(:+)
        observations << mu - adjustments
      end
      observation_hash[profile.role_instances] = observations
    end
    observation_hash
  end
  
  def get_sd(observation_hash)
    observation_hash.values.flatten.to_scale.sd
  end
  
  #equilibrium = {role: {strategy: prob}}
  def estimate_value(equilibrium, agents_per_player)
    @observation_hash.delete_if{|k,v| k.detect{|r| r.strategy_instances.detect{|s| s.count % agents_per_player != 0}}}
    @observation_hash.collect do |roles, observations|
      role_facts = {}
      roles.each {|r| role_facts[r.name] = fact(r.strategy_instances.collect{|s| s.count/agents_per_player }.reduce(:+)) }
      roles.collect{|r| role_facts[r.name]*r.strategy_instances.collect{|s| (1.0/fact(s.count/agents_per_player))*equilibrium[r.name][s.name]**(s.count/agents_per_player) }.reduce(:*) }.reduce(:*)*(observations.to_scale.mean)
    end.reduce(:+)
  end
  
  private
  
  def fact(n)
    (1..n).reduce(:*)
  end
  
  def get_profiles(role_strategy_hash)
    query_hash = {:name => strategy_regex(role_strategy_hash), :sample_count.gt => 0}
    @game.roles.each {|r| query_hash["Role_#{r.name}_count"] = r.count}
    @game.profiles.where(query_hash)
  end
  
  def strategy_regex(role_strategy_hash)
    Regexp.new("^"+role_strategy_hash.keys.sort.collect{|r| "#{r}: \\d+ (#{role_strategy_hash[r].join('(, \\d+ )?)*(')}(, \\d+ )?)*"}.join("; ")+"$")
  end
end