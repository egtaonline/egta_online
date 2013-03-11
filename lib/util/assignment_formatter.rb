class AssignmentFormatter
  def self.format_assignments(assignments)
    assignments.collect{ |a| format_assignment(a) }
  end

  def self.format_assignment(assignment)
    assignment.collect{ |rc| format_role_combination(rc) }.join('; ')
  end

  private

  def self.format_role_combination(role_combination)
    strategies = role_combination.drop(1)
    "#{role_combination[0]}: " + strategies.uniq.collect{ |s| "#{strategies.count(s)} #{s}" }.join(", ")
  end
end