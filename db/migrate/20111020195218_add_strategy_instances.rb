class AddStrategyInstances < Mongoid::Migration
  def self.up
    mongo_db = Profile.db
    total = Profile.count
    count = 0
    while total > 0
      if total < 50
        cursor = Profile.skip(50*count).limit(total)
      else
        cursor = Profile.skip(50*count).limit(50)
      end
      cursor.each do |p|
        if p.role_instances.first != nil
          p.proto_string.split(": ")[1].split(", ").uniq.each do |s|
            if p["payoff_avgs"] != nil
              p.role_instances.first.strategy_instances.find_or_create_by(name: s, payoff: p.payoff_avgs[s], payoff_std: p.payoff_stds[s])
            else
              p.role_instances.first.strategy_instances.find_or_create_by(name: s)
            end
            p.role_instances.first.remove_attribute("payoff_avgs")
            p.role_instances.first.remove_attribute("payoff_stds")
          end
        end
      end
      count += 1
      total -= 50
      puts total
    end
  end

  def self.down
  end
end