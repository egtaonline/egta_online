class GameScheduler < Scheduler
  include RoleManipulator::Scheduler
  include Sampling::Simple
  include SubgameScheduler

  validates_presence_of :size

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
end