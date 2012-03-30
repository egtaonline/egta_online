class StrategyInstanceCounts < Mongoid::Migration
  def self.up
    Profile.all.each do |p|
      p.role_instances.all.each do |r|
        r.strategy_instances.all.each do |s|
          count = 0
          p.name.split("; ").each do |pr|
            if pr.split(": ")[0] == r.name
              pr.split(": ")[1].split(", ").each do |strat|
                count = strat.split(" ")[0].to_i if strat.split(" ")[1] == s.name
              end
            end
          end
          s.update_attribute(:count, count)
        end
      end
    end
  end

  def self.down
  end
end