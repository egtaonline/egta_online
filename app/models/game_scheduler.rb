class GameScheduler < Scheduler
  
  field :size, :type => Integer
  field :role_strategy_hash, type: Hash, default: {}
  field :role_count_hash, type: Hash, default: {}
  validates_presence_of :size
  
  def add_strategy_by_name(role, strategy)
    role_strategy_hash[role] = [] if role_strategy_hash[role] == nil
    role_strategy_hash[role] << strategy
    hash = role_strategy_hash
    self.update_attribute(:role_strategy_hash, nil)
    self.update_attribute(:role_strategy_hash, hash)
    Resque.enqueue(ProfileAssociater, self.id)
  end
  
  def delete_strategy_by_name(role, strategy)
    role_strategy_hash[role].delete(strategy)
    hash = role_strategy_hash
    pids = []
    Profile.find(profile_ids).each {|profile| pids << profile.id if profile.contains_strategy?(role, strategy) == false}
    self.update_attribute(:role_strategy_hash, nil)
    self.update_attributes(role_strategy_hash: hash, profile_ids: pids)
  end
  
  def ensure_profiles
    if role_strategy_hash.keys.size == 0
      return []
    end
    proto_strings = []
    first_ar = nil
    all_other_ars = []
    role_strategy_hash.each do |key, value|
      if first_ar == nil
        first_ar = value.repeated_combination(role_count_hash[key])
      else
        all_other_ars << value.repeated_combination(role_count_hash[key])
      end
    end
    if role_strategy_hash.keys.size == 1
      return first_ar.collect {|e| "All: "+e.join(", ")}
    else
      return first_ar.product(all_other_ars).collect do |prof|
        count = -1
        role_strategy_hash.keys.collect {|key| count+=1; key+": "+prof[count].join(", ")}.join("; ")
      end
    end
  end
end