class GameScheduler < Scheduler
  include RoleManipulator::Scheduler

  validates_numericality_of :default_samples, :size, greater_than: 0
  validates_presence_of :size

  def required_samples(profile)
    profile.scheduler_ids.include?(self.id) ? default_samples : 0
  end
  
  def profile_space
    return [] if invalid_role_partition?
    first_rc, all_other_rcs = subgame_combinations
    return first_rc.collect { |r| format_role(r) } if single_role?
    profs = []
    first_rc.product(*all_other_rcs).each do |prof|
      prof.sort!{|x, y| x[0] <=> y[0]}
      profs << prof.collect {|r| format_role(r) }.join("; ")
    end
    profs
  end
  
  protected
  
  def format_role(role)
    strats = role.drop(1)
    "#{role[0]}: " + strats.uniq.collect{|s| "#{strats.count(s)} #{s}" }.join(", ")
  end
  
  def invalid_role_partition?
    (roles.collect{ |role| role.count }.reduce(:+) != size) | roles.detect{ |r| r.strategies.count == 0 }
  end
  
  def single_role?
    (roles.size == 1) | (roles.map{ |r| r.strategies.count }.reduce(:+) == roles.first.strategies.count)
  end
  
  def subgame_combinations
    rcs = roles.collect{ |role| role.strategies.repeated_combination(role.count).collect{|c| [role.name].concat(c) } }
    return rcs[0], rcs.drop(1)
  end

  def add_strategies_to_game(game)
    roles.each do |r|
      game.roles.create!(name: r.name, count: r.count)
      r.strategies.each{ |s| game.add_strategy(r.name, s) }
    end
  end
end