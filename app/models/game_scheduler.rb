class GameScheduler < Scheduler
  include RoleManipulator::Scheduler
  
  field :default_samples, type: Integer
  embeds_many :roles, as: :role_owner, order: :name.asc
  validates :default_samples, presence: true, numericality: { integer_only: true, greater_than: 0 }

  def required_samples(profile_id)
    (self.profiles.find(profile_id) rescue nil) == nil ? 0 : default_samples
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
end