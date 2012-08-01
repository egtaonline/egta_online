class AddSizeToGenericSchedulers < Mongoid::Migration
  def self.up
    GenericScheduler.all.each do |scheduler|
      if scheduler.profiles.first == nil
        p "destroy"
      else
        p "keep"
        scheduler.roles.destroy_all
        scheduler.profiles.first.symmetry_groups.collect{|symmetry_group| symmetry_group.role}.uniq.each do |role|
          scheduler.add_role(role, scheduler.profiles.first.symmetry_groups.where(role: role).collect{ |s| s.count }.reduce(:+) )
        end
        scheduler.update_attribute(:size, scheduler.profiles.first.size)
      end
    end
  end

  def self.down
  end
end