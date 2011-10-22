class GameScheduler < Scheduler
  
  field :size, :type => Integer
  validates_presence_of :size
  
  def add_strategy(role, strategy)
    role_i = roles.find_or_create_by(name: role)
    role_i.strategy_array << strategy
    role_i.save!
    puts "CALLED"
    puts Resque.enqueue(ProfileAssociater, self.id)
  end
  
  def remove_strategy(role, strategy)
    role_i = roles.where(name: role).first
    role_i.strategy_array.delete(strategy)
    role_i.save!
    pids = []
    Profile.find(profile_ids).each {|profile| pids << profile.id if profile.contains_strategy?(role, strategy) == false}
    self.update_attributes(profile_ids: pids)
  end
  
  def ensure_profiles
    if roles.reduce(0){|sum, r| sum + r.count} != size || roles.collect{|r| r.strategy_array.size}.min < 1
      return []
    end
    proto_strings = []
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      if first_ar == nil
        first_ar = role.strategy_array.sort.repeated_combination(role.count).to_a
      else
        all_other_ars << role.strategy_array.sort.repeated_combination(role.count).to_a
      end
    end
    puts first_ar.inspect
    puts all_other_ars.inspect
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategy_array.size} == roles.first.strategy_array.size
      return first_ar.collect {|e| "#{roles.first}: "+e.join(", ")}
    else
      ret = []
      first_ar.to_a.product(*all_other_ars).each do |prof|
        count = -1
        ret << roles.collect {|r| count+=1; r.name+": "+prof[count].join(", ")}.join("; ")
      end
    end
    ret
  end
  
  def unassigned_player_count
    size-roles.reduce(0) {|n, r| n+r.count}
  end
end