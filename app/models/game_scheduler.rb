class GameScheduler < Scheduler
  
  field :size, :type => Integer
  validates_presence_of :size
  
  def add_strategy_by_name(role, strategy)
    role_i = roles.find_or_create_by(name: role)
    role_i.strategy_array << strategy
    role_i.save!
    Resque.enqueue(ProfileAssociater, self.id)
  end
  
  def delete_strategy_by_name(role, strategy)
    role_i = roles.where(name: role).first
    role_i.strategy_array.delete(strategy)
    role_i.save!
    pids = []
    Profile.find(profile_ids).each {|profile| pids << profile.id if profile.contains_strategy?(role, strategy) == false}
    self.update_attributes(profile_ids: pids)
  end
  
  def ensure_profiles
    if roles.size == 0 || roles.reduce {|sum, r| sum + r.strategy_array.size} == 0
      return []
    end
    proto_strings = []
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      if first_ar == nil
        first_ar = role.strategy_array.repeated_combination(role.count)
      else
        all_other_ars << role.strategy_array.repeated_combination(role.count)
      end
    end
    if roles.size == 1
      return first_ar.collect {|e| "All: "+e.join(", ")}
    else
      return first_ar.product(all_other_ars).collect do |prof|
        count = -1
        roles.collect {|r| count+=1; r.name+": "+prof[count].join(", ")}.join("; ")
      end
    end
  end
end