class FixingHierarchicalSchedulers < Mongoid::Migration
  def self.up
    HierarchicalScheduler.all.each do |hs|
      hs.roles.each do |role|
        role.update_attributes(count: role.count*hs['agents_per_player'], reduced_count: role.count)
      end
    end
    HierarchicalDeviationScheduler.all.each do |hs|
      hs.roles.each do |role|
        role.update_attributes(count: role.count*hs['agents_per_player'], reduced_count: role.count)
      end
      hs.deviating_roles.each do |role|
        role.update_attributes(count: role.count*hs['agents_per_player'], reduced_count: role.count)
      end
    end
  end

  def self.down
    HierarchicalScheduler.all.each do |hs|
      hs.roles.each do |role|
        role.update_attributes(count: role.reduced_count)
      end
    end
    HierarchicalDeviationScheduler.all.each do |hs|
      hs.roles.each do |role|
        role.update_attributes(count: role.reduced_count)
      end
      hs.deviating_roles.each do |role|
        role.update_attributes(count: role.reduced_count)
      end
    end
  end
end