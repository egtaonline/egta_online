class HierarchicalDeviationScheduler < AbstractionScheduler
  include HierarchicalReduction
  include Deviations

  def profile_space
    return [] if invalid_role_partition?
    deviations = get_deviations
    multiples = {}
    roles.each { |r| multiples[r.name] = r.count/r.reduced_count }
    first_ar, all_other_ars = arrays_to_cross
    profs = []
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategies.count} == roles.first.strategies.count
      first_ar.concat(deviations[roles.first.name])
      profs = first_ar.collect {|r| format_role(r, multiples[r[0]]) }
    else
      first_ar.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| format_role(r, multiples[r[0]]) }.join("; ")
      end
      all_other_ars << first_ar

      deviations.each do |key, value|
        non_deviations = all_other_ars.select{|val| val[0][0] != key}
        value.product(*non_deviations).each do |prof|
          prof.sort!{|x, y| x[0] <=> y[0]}
          profs << prof.collect {|r| format_role(r, multiples[r[0]]) }.join("; ")
        end
      end
    end
    profs.uniq
  end

  protected

  def add_strategies_to_game(game)
    super
    deviating_roles.each{ |r| r.strategies.each{ |s| add_strategy(r.name, s) } }
  end
end