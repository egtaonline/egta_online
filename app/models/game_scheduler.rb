class GameScheduler < Scheduler
  include RoleManipulator
  field :max_samples, :type => Integer
  embeds_many :roles, :as => :role_owner, :order => :name.asc
  field :size, :type => Integer
  validates_presence_of :size, :max_samples
  validates_numericality_of :max_samples

  def required_samples(profile_id)
    if (self.profiles.find(profile_id) rescue nil) == nil
      0
    else
      max_samples
    end
  end

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
    if role_i != nil
      role_i.strategies = role_i.strategies.where(:name.ne => strategy_name)
      role_i.save!
      self.profiles -= self.profiles.with_role_and_strategy(role, strategy_name)
      self.save
    end
  end

  def ensure_profiles
    if roles.reduce(0){|sum, r| sum + r.count} != size || roles.collect{|r| r.strategies.count}.min < 1
      return []
    end
    first_ar = nil
    all_other_ars = []
    roles.each do |role|
      combinations = role.strategy_numbers.repeated_combination(role.count).to_a
      if first_ar == nil
        first_ar = combinations.collect{|c| [role.name].concat(c) }
      else
        all_other_ars << combinations.collect{|c| [role.name].concat(c) }
      end
    end
    if roles.size == 1 || roles.reduce(0){|sum, r| sum + r.strategies.count} == roles.first.strategies.count
      return first_ar.collect {|r| "#{r[0]}: #{r.drop(1).join(", ")}"}
    else
      profs = []
      first_ar.product(*all_other_ars).each do |prof|
        prof.sort!{|x, y| x[0] <=> y[0]}
        profs << prof.collect {|r| "#{r[0]}: #{r.drop(1).join(", ")}"}.join("; ")
      end
    end
    profs
  end
end