class String
  def assignment_sort
    roles = self.split("; ").collect { |role| role.split(": ") }
    roles = roles.sort.collect{ |role| role[0]+": "+ role[1].strategy_sort }.join("; ")
  end
  
  def strategy_sort
    self.split(", ").sort{ |x,y| x.split(" ")[1] <=> y.split(" ")[1] }.join(", ")
  end
end