class VariableEstimator
  
  attr_accessor :control_variables
  
  #control_variables = {name: {expected_value: value}}
  def initialize(game, target_variable, control_variables, role_strategy_hash)
    @game, @target_variable, @control_variables = game, target_variable, control_variables
    @profiles = get_profiles(role_strategy_hash)
    calculate_coefficients
    apply_coefficients
  end
  
  def calculate_coefficients
    observations = []
    feature_hash = Hash.new {|hash, key| hash[key] = []}
    @profiles.each do |profile|
      profile.sample_records.limit(10).collect do |sample_record|
        flag = true
        @control_variables.keys.each do |name|
          flag = false if sample_record.features[name] == nil
        end
        if flag
          @control_variables.keys.each do |name|
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
      @control_variables.keys.each do |key|
        @control_variables[key]["coeff"] = lr.coeffs[key]
      end
    end
  end
  
  def apply_coefficients
    @observation_hash = {}
    before = []
    after = []
    @profiles.each do |profile|
      observations = []
      profile.sample_records.skip(10).each do |sample_record|
        before << sample_record.features[@target_variable]
        adjusted = sample_record.features[@target_variable]-(@control_variables.collect{|name, value| sample_record.features[name] == nil ? 0 : value["coeff"]*(sample_record.features[name]-value["expected_value"])}.reduce(:+))
        observations << adjusted
        after << adjusted
      end
      @observation_hash[profile.role_instances] = observations
    end
    puts "before: #{before.to_scale.sd}\nafter: #{after.to_scale.sd}"
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