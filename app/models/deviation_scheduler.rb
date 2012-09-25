class DeviationScheduler < GameScheduler
  embeds_many :deviating_roles, class_name: "Role", as: :role_owner

  def add_role(name, count=nil)
    super
    deviating_roles.find_or_create_by(name: name, count: count)
  end

  def remove_role(name)
    super
    deviating_roles.where(name: name).destroy_all
  end

  def add_strategy(role_name, strategy_name)
    role = deviating_roles.where(name: role_name).first
    if !role.strategies.include?(strategy_name)
      role_i = roles.find_or_create_by(name: role_name)
      role_i.strategies << strategy_name
      role_i.strategies.sort!
      role_i.save!
      Resque.enqueue(ProfileAssociater, self.id)
    end
  end

  def add_deviating_strategy(role_name, strategy_name)
    role = roles.where(name: role_name).first
    if !role.strategies.include?(strategy_name)
      role_i = deviating_roles.find_or_create_by(name: role_name)
      role_i.strategies << strategy_name
      role_i.strategies.sort!
      role_i.save!
      Resque.enqueue(ProfileAssociater, self.id)
    end
  end

  def remove_deviating_strategy(role_name, strategy_name)
    role_i = deviating_roles.where(name: role_name).first
    role_i.strategies.delete(strategy_name)
    self.save
    Resque.enqueue(StrategyRemover, self.id)
  end

  def available_strategies(role_name)
    super-deviating_strategies_for(role_name)
  end

  def deviating_strategies_for(role_name)
    role = deviating_roles.where(name: role_name).first
    role == nil ? [] : role.strategies
  end

  def profile_space
    return [] if invalid_role_partition?
    first_rc, all_other_rcs = subgame_combinations
    deviations = get_deviations
    return first_rc.concat(deviations[roles.first.name]).collect{ |r| format_role(r) } if single_role?
    profs = []
    first_rc.product(*all_other_rcs).each do |prof|
      prof.sort!{|x, y| x[0] <=> y[0]}
      profs << prof.collect {|r| format_role(r)}.join("; ")
    end
    all_other_rcs << first_rc

    deviations.each do |key, value|
      non_deviations = all_other_rcs.select{|val| val[0][0] != key}
      value.product(*non_deviations).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| format_role(r)}.join("; ")
      end
    end
    profs
  end

  protected

  def add_strategies_to_game(game)
    super
    deviating_roles.each{ |r| r.strategies.each{ |s| add_strategy(r.name, s) } }
  end

  def get_deviations
    deviations = {}
    deviating_roles.each do |role|
      deviation = role.strategies.product(roles.where(name: role.name).first.strategies.repeated_combination(role.count-1).to_a)
      deviations[role.name] = deviation.collect {|a| [role.name].concat ([a[0]].push(*a[1]).sort) }
    end
    deviations
  end
end