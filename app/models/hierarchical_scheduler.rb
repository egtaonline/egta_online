class HierarchicalScheduler < AbstractionScheduler
  include HierarchicalReduction

  def profile_space
    return [] if invalid_role_partition?
    multiples = {}
    roles.each { |r| multiples[r.name] = r.count/r.reduced_count }
    first_ar, all_other_ars = arrays_to_cross
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategies.count} == roles.first.strategies.count
      return first_ar.collect {|r| format_role(r, multiples[r[0]])}
    else
      profs = []
      first_ar.to_a.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| format_role(r, multiples[r[0]])}.join("; ")
      end
    end
    profs
  end
end