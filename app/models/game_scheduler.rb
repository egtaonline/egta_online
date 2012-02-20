class GameScheduler < Scheduler
  include RoleManipulator

  field :size, :type => Integer
  validates_presence_of :size

  def add_strategy(role, strategy_name)
    super
    Resque.enqueue(ProfileAssociater, self.id)
  end

  def remove_role(role_name)
    super
    self.profiles = []
    self.save
  end

  def remove_strategy(role, strategy_name)
    role_i = roles.where(name: role).first
    role_i.strategies = role_i.strategies.where(:name.ne => strategy_name)
    role_i.save!
    self.profiles -= self.profiles.with_role_and_strategy(role, strategy_name)
    self.save
  end

  def ensure_profiles
    if roles.reduce(0){|sum, r| sum + r.count} != size || roles.collect{|r| r.strategies.count}.min < 1
      return []
    end
    proto_strings = []
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      combinations = role.strategy_numbers.repeated_combination(role.count).to_a
      if first_ar == nil
        first_ar = combinations
      else
        all_other_ars << combinations
      end
    end
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategies.count} == roles.first.strategies.count
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