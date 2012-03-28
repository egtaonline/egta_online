class Strategy
  include Mongoid::Document
  field :name
  field :number
end

class SimplifyingStrategies < Mongoid::Migration
  
  def self.up
    puts Profile.count
    db = Simulator.db
    Simulator.all.each do |s|
      s.roles.each do |r|
        r.strategies = []
        Strategy.where(:_id.in => r.strategy_ids).each do |strat|
          r.strategies << strat.name
        end
      end
      s.save
      s.reload
      puts s.roles.inspect
    end
    puts Profile.count
    Game.all.each do |g|
      g.roles.each do |r|
        r.strategies = []
        Strategy.where(:_id.in => r.strategy_ids).each do |strat|
          r.strategies << strat.name
        end
      end
      g.save
      g.reload
      puts g.roles.inspect
    end
    puts Profile.count
    Scheduler.all.each do |s|
      if s.is_a?(GenericScheduler) == false
        s.roles.each do |r|
          r.strategies = []
          Strategy.where(:_id.in => r.strategy_ids).each do |strat|
            r.strategies << strat.name
          end
        end
        s.save
        s.reload
        puts s.roles.inspect
      end
    end
    puts Profile.count
    db.collection("strategies").drop
    puts Profile.count
    db.collection("profiles").update({}, {"$unset" => {"proto_string" => 1}}, multi: true)
  end

  def self.down
  end
end