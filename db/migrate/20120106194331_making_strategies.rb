class MakingStrategies < Mongoid::Migration
  def self.up
    Simulator.all.each do |s|
      s.roles.each do |role|
        if role["strategy_array"] != nil
          role["strategy_array"].each do |strategy|
            role.strategies.find_or_create_by(:name => strategy)
          end
          role.unset(:strategy_array)
        end
      end
    end
    Game.all.each do |g|
      g.roles.each do |role|
        if role["strategy_array"] != nil
          role.strategies = Strategy.where(:name.in => role["strategy_array"]).to_a
          role.save!
          role.unset(:strategy_array) if role.strategies.count == role["strategy_array"].size
        end
      end
    end
    Scheduler.all.each do |g|
      g.roles.each do |role|
        if role["strategy_array"] != nil
          role.strategies = Strategy.where(:name.in => role["strategy_array"]).to_a
          role.save!
          role.unset(:strategy_array) if role.strategies.count == role["strategy_array"].size
        end
      end
    end
    Profile.all.each do |p|
      str = p.proto_string
      str = str.split("; ").collect{|role| role.split(": ")[0]+": "+role.split(": ")[1].split(", ").collect{|s| Strategy.where(:name => s).first.number}.join(", ")}.join("; ")
      p.update_attribute(:proto_string, str)
    end
  end

  def self.down
  end
end